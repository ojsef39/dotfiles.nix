# Function to display and launch Talos dashboard with all nodes
# TODO: Better cancel behaviour
# Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/399
# labels: os:darwin, device:personal, enhancement

# TODO: Dont upgrade nodes when they are already on the target version (unless specified with flag)
# Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/398
# labels: os:darwin, device:personal, enhancement
function talos_dashboard
    # Get all cluster members
    echo "🔍 Fetching cluster members..."

    # Parse member hostnames
    set -l control_hostnames
    set -l worker_hostnames
    set -l nodes_args

    # Process the output line by line
    for line in (talosctl get members -o yaml | grep "hostname:" | awk '{print $2}')
        set node_hostname (string trim $line)
        if test -n "$node_hostname"
            # Check if it's a control plane node
            if string match -q "*control*" "$node_hostname"
                set -a control_hostnames $node_hostname
            else
                set -a worker_hostnames $node_hostname
            end
            # Add to nodes_args array
            set -a nodes_args -n $node_hostname
        end
    end

    # If no members were found, run dashboard without -n flags
    if test (count $nodes_args) -eq 0
        echo "⚠️ No cluster members found. Running dashboard without node specification."
        talosctl dashboard
    else
        echo "🚀 Starting dashboard with nodes:"

        # Display control plane nodes first with special marker
        for node_hostname in $control_hostnames
            echo "  🎮 $node_hostname"
        end

        # Display worker nodes
        for node_hostname in $worker_hostnames
            echo "  🛠️ $node_hostname"
        end

        # Run the dashboard with proper array expansion
        talosctl dashboard $nodes_args

        # Return with a clean exit code
        return 0
    end
end

# Main function to set up Talos context and launch dashboard
function talos_context
    # Fetch all items from the vault "JHC" in the category "API Credential" with names containing "talos"
    set items (op item list --vault "JHC" --categories "API Credential" --format json | jq -r '.[] | select(.title | contains("talos")) | .id + " " + .title')

    # Process items into a format that fzf can display line by line
    set formatted_items
    for item in $items
        set -a formatted_items "$item"
    end

    # Use fzf to select an item
    set selected_item (printf "%s\n" $formatted_items | fzf --delimiter " " --with-nth 2.. | awk '{print $1}')

    # If no item was selected, exit the function
    if test -z "$selected_item"
        echo "No item selected. Exiting."
        return 1
    end

    # Extract the title from the selected item
    set selected_title (printf "%s\n" $formatted_items | grep "$selected_item" | awk '{$1=""; print substr($0,2)}')

    op item get "$selected_item" --vault JHC --format json | jq -r '.fields[] | select(.label == "text") | .value' >/tmp/talosconfig

    # Set environment variable
    set -gx TALOSCONFIG /tmp/talosconfig

    # Extract endpoints from the talosconfig
    set current_context (grep "^context:" /tmp/talosconfig | awk '{print $2}')
    if test -z "$current_context"
        echo "Error: Could not determine current context from talosconfig"
        return 1
    end

    # Extract endpoints for the current context
    set endpoints (awk -v context="$current_context:" '
        $0 ~ context {in_context=1; next}
        in_context && /^[[:space:]]+endpoints:/ {in_endpoints=1; next}
        in_context && in_endpoints && /^[[:space:]]+- / {print $2; next}
        in_context && /^[[:space:]]+[a-z]+:/ && in_endpoints {exit}
    ' /tmp/talosconfig)

    if test -z "$endpoints"
        echo "Error: No endpoints found for context '$current_context'"
        return 1
    end

    # Try each endpoint until one succeeds
    mkdir -p ~/.kube
    set success 0
    for endpoint in $endpoints
        echo "Trying endpoint: $endpoint"
        if talosctl kubeconfig --talosconfig=/tmp/talosconfig --nodes "$endpoint" --force
            echo "Successfully generated kubeconfig using endpoint: $endpoint"
            set success 1
            break
        else
            echo "Failed to connect to $endpoint, trying next..."
        end
    end

    if test $success -eq 0
        echo "Error: Failed to generate kubeconfig from any endpoint"
        return 1
    end

    # Copy the config file with the selected title
    if test -n "$selected_title" -a -f ~/.kube/config
        cp ~/.kube/config ~/.kube/"$selected_title"
    end
end

# Function to upgrade all Talos nodes one by one
function talos_upgrade
    set -l k8s_mode false
    set -l upgrade_args
    set -l rpi_image

    # Check for --k8s and --i-rpi flags
    set -l skip_next false
    for i in (seq (count $argv))
        if $skip_next
            set skip_next false
            continue
        end

        set arg $argv[$i]
        if test "$arg" = --k8s
            set k8s_mode true
        else if test "$arg" = --i-rpi
            # Next argument is the RPI image
            if test $i -lt (count $argv)
                set rpi_image $argv[(math $i + 1)]
                set skip_next true
            end
        else if not $skip_next
            set -a upgrade_args $arg
        end
    end

    # Special case: if k8s mode is specified with no args, that's valid
    # Check if arguments are provided
    if test (count $upgrade_args) -eq 0; and not $k8s_mode
        echo "❌ Usage: talos_upgrade <talosctl-upgrade-args>"
        echo "   Example: talos_upgrade -i factory.talos.dev/installer/abc123:v1.10.3"
        echo "   Example: talos_upgrade -i factory.talos.dev/installer/abc123:v1.10.3 --preserve"
        echo ""
        echo "   For clusters with Raspberry Pi nodes, use --i-rpi flag:"
        echo "   Example: talos_upgrade -i factory.talos.dev/installer/abc:v1.10.6 --i-rpi ghcr.io/talos-rpi5/installer:v1.10.6-rpi5"
        echo "   Example: talos_upgrade -i factory.talos.dev/installer/abc:v1.10.6 --i-rpi ghcr.io/talos-rpi5/installer:v1.10.6-rpi5 --preserve"
        echo ""
        echo "   For Kubernetes upgrades, use --k8s flag:"
        echo "   Example: talos_upgrade --k8s"
        echo "   Example: talos_upgrade --k8s --to 1.29.0"
        echo "   Example: talos_upgrade --k8s --from 1.28.0 --to 1.29.0"
        return 1
    end

    # Set command and message based on mode
    set -l upgrade_cmd upgrade
    if $k8s_mode
        if test (count $upgrade_args) -eq 0
            echo "🔄 Starting Kubernetes upgrade to latest version"
        else
            echo "🔄 Starting Kubernetes upgrade with args: $upgrade_args"
        end
        set upgrade_cmd upgrade-k8s
    else
        echo "🔄 Starting Talos OS upgrade with args: $upgrade_args"
    end

    # Get all cluster members
    echo "🔍 Fetching cluster members..."

    set -l control_hostnames
    set -l worker_hostnames

    # Process the output line by line to categorize nodes
    for line in (talosctl get members -o yaml | grep "hostname:" | awk '{print $2}')
        set node_hostname (string trim $line)
        if test -n "$node_hostname"
            # Check if it's a control plane node
            if string match -q "*control*" "$node_hostname"
                set -a control_hostnames $node_hostname
            else
                set -a worker_hostnames $node_hostname
            end
        end
    end

    # If no members were found, exit
    if test (count $control_hostnames) -eq 0 -a (count $worker_hostnames) -eq 0
        echo "⚠️ No cluster members found."
        return 1
    end

    # Check if any RPI nodes exist and validate --i-rpi flag
    set -l has_rpi_nodes false
    for node_hostname in $control_hostnames $worker_hostnames
        if string match -q "*rpi*" "$node_hostname"
            set has_rpi_nodes true
            break
        end
    end

    if $has_rpi_nodes; and test -z "$rpi_image"; and not $k8s_mode
        echo "❌ Error: Raspberry Pi nodes detected but --i-rpi flag not provided."
        echo "   Usage: talos_upgrade -i <regular-image> --i-rpi <rpi-image> [options]"
        echo "   Example: talos_upgrade -i factory.talos.dev/installer/abc:v1.10.6 --i-rpi ghcr.io/talos-rpi5/installer:v1.10.6-rpi5"
        return 1
    end

    # Display discovered nodes
    for node_hostname in $control_hostnames
        if string match -q "*rpi*" "$node_hostname"
            echo "  🎮🥧 $node_hostname (RPI)"
        else
            echo "  🎮 $node_hostname"
        end
    end

    if not $k8s_mode
        for node_hostname in $worker_hostnames
            if string match -q "*rpi*" "$node_hostname"
                echo "  🛠️🥧 $node_hostname (RPI)"
            else
                echo "  🛠️ $node_hostname"
            end
        end
    end

    echo ""

    # Upgrade k8s: Run on one control plane node only (it will update all nodes)
    if $k8s_mode; and test (count $control_hostnames) -gt 0
        echo "🎮 Upgrading Kubernetes (using first control plane)..."

        # Only run on first control plane node
        set first_node $control_hostnames[1]
        echo "🔄 Running Kubernetes upgrade via $first_node"

        talosctl $upgrade_cmd $upgrade_args -n $first_node

        if test $status -ne 0
            echo "❌ Failed to upgrade Kubernetes"
            return 1
        end
        # Talos upgrade: Upgrade control plane nodes first
    else if test (count $control_hostnames) -gt 0
        echo "🎮 Upgrading control planes..."
        for node_hostname in $control_hostnames
            # Determine which image to use based on hostname
            set -l node_upgrade_args $upgrade_args
            if string match -q "*rpi*" "$node_hostname"
                # Replace -i argument with RPI image
                set node_upgrade_args
                set -l skip_next false
                for arg in $upgrade_args
                    if $skip_next
                        set skip_next false
                        continue
                    else if test "$arg" = "-i"
                        set -a node_upgrade_args -i $rpi_image
                        set skip_next true
                    else
                        set -a node_upgrade_args $arg
                    end
                end
            end

            # Run the upgrade command with appropriate image and current node
            talosctl $upgrade_cmd $node_upgrade_args -n $node_hostname

            if test $status -ne 0
                echo "❌ Failed to upgrade: $node_hostname"
                return 1
            end

            # Check if this is not the last control plane node
            if test $node_hostname != $control_hostnames[-1]
                echo "⏳ Press Enter to continue with next control plane, or Ctrl+C to abort:"
                read -l continue_upgrade
            end
        end

        # Wait 30 seconds between control plane and worker nodes
        if test (count $worker_hostnames) -gt 0
            echo ""
            echo "⏳ Waiting 30 seconds before upgrading worker nodes..."
            sleep 30
            echo ""
        end
    end

    # Upgrade worker nodes (only for OS upgrades, not for k8s upgrades)
    if not $k8s_mode; and test (count $worker_hostnames) -gt 0
        echo "🛠️ Upgrading workers..."
        for node_hostname in $worker_hostnames
            # Determine which image to use based on hostname
            set -l node_upgrade_args $upgrade_args
            if string match -q "*rpi*" "$node_hostname"
                # Replace -i argument with RPI image
                set node_upgrade_args
                set -l skip_next false
                for arg in $upgrade_args
                    if $skip_next
                        set skip_next false
                        continue
                    else if test "$arg" = "-i"
                        set -a node_upgrade_args -i $rpi_image
                        set skip_next true
                    else
                        set -a node_upgrade_args $arg
                    end
                end
            end

            # Run the upgrade command with appropriate image and current node
            talosctl $upgrade_cmd $node_upgrade_args -n $node_hostname

            if test $status -ne 0
                echo "❌ Failed to upgrade: $node_hostname"
                return 1
            end

            # Check if this is not the last worker node
            if test $node_hostname != $worker_hostnames[-1]
                echo "⏳ Press Enter to continue with next worker, or Ctrl+C to abort:"
                read -l continue_upgrade
            end
        end
    end

    echo ""
    if $k8s_mode
        echo "🎉 Kubernetes has been upgraded on all nodes!"
    else
        echo "🎉 All nodes have been upgraded!"
    end
    return 0
end
