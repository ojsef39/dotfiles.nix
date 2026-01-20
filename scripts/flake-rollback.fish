#!/usr/bin/env fish

# Nix Flake Input Revert Tool
# Helps revert specific flake inputs to their previous versions

# Check prerequisites
function check_prerequisites
    set -l flake_dir $argv[1]
    if not test -f "$flake_dir/flake.lock"
        echo "$(set_color red) Error: flake.lock not found in $flake_dir$(set_color normal)"
        exit 1
    end

    for cmd in git fzf jq
        if not command -v $cmd >/dev/null 2>&1
            echo "$(set_color red) Error: $cmd is required but not found$(set_color normal)"
            exit 1
        end
    end

    if not git -C "$flake_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "$(set_color red) Error: not in a git repository ($flake_dir)$(set_color normal)"
        exit 1
    end
end

# Get previous flake.lock from git
function get_previous_lock
    set -l flake_dir $argv[1]
    set prev_lock (mktemp)
    # Try to get flake.lock from previous commit (HEAD^), fallback to HEAD if not available
    if git -C "$flake_dir" rev-parse HEAD^ >/dev/null 2>&1
        if not git -C "$flake_dir" show HEAD^:flake.lock >$prev_lock 2>/dev/null
            echo "$(set_color red) Error: Could not get flake.lock from previous commit (HEAD^)$(set_color normal)"
            rm -f $prev_lock
            exit 1
        end
    else
        if not git -C "$flake_dir" show HEAD:flake.lock >$prev_lock 2>/dev/null
            echo "$(set_color red) Error: Could not get previous version of flake.lock from git$(set_color normal)"
            rm -f $prev_lock
            exit 1
        end
    end
    echo $prev_lock
end

# Get node information for an input
function get_input_nodes
    set -l lock_file $argv[1]
    set -l input_name $argv[2]

    # Get nodes for this input (can be string or array)
    set -l nodes_json (jq -c --arg input "$input_name" '.nodes.root.inputs[$input]' $lock_file 2>/dev/null)

    if test "$nodes_json" = null -o -z "$nodes_json"
        return 1
    end

    # Handle both string and array cases
    if string match -q '"*"' $nodes_json
        # Single node (string) - remove quotes
        echo (echo $nodes_json | sed 's/"//g')
    else
        # Multiple nodes (array) - extract each element
        echo $nodes_json | jq -r '.[]'
    end
end

# Get revision for a node
function get_node_revision
    set -l lock_file $argv[1]
    set -l node_name $argv[2]

    jq -r --arg node "$node_name" '.nodes[$node].locked.rev // empty' $lock_file 2>/dev/null
end

# Get URL for a node (for better identification)
function get_node_url
    set -l lock_file $argv[1]
    set -l node_name $argv[2]

    jq -r --arg node "$node_name" '.nodes[$node].locked.url // .nodes[$node].original.url // empty' $lock_file 2>/dev/null
end

# Format change entry with better duplicate handling
function format_change_entry
    set -l input_name $argv[1]
    set -l node_name $argv[2]
    set -l prev_rev $argv[3]
    set -l curr_rev $argv[4]
    set -l node_url $argv[5]
    set -l node_index $argv[6]
    set -l total_nodes $argv[7]

    # Handle empty previous revision
    if test -z "$prev_rev"
        set prev_rev new
    end

    set -l short_prev (string sub -l 8 $prev_rev)
    set -l short_curr (string sub -l 8 $curr_rev)

    # Create display string with better duplicate identification
    set -l display_name "$input_name"

    # Only add disambiguation if there are multiple nodes and total_nodes is a valid number
    if test -n "$total_nodes" -a "$total_nodes" -gt 1
        # Show index and URL for disambiguation
        set display_name "$input_name #$node_index"
        if test -n "$node_url"
            set -l short_url (string replace -r '^https?://([^/]+).*' '$1' $node_url)
            set display_name "$display_name ($short_url)"
        end
    end

    if test "$display_name" = "$node_name"
        echo "$display_name ($short_prev → $short_curr)"
    else
        echo "$display_name [$node_name] ($short_prev → $short_curr)"
    end
end

# Get all changed inputs with better duplicate handling
function get_changed_inputs
    set -l flake_dir $argv[1]
    set -l current_lock "$flake_dir/flake.lock"
    set -l prev_lock (get_previous_lock $flake_dir)
    set -l changed_entries

    # Get all input names from current lock
    set -l inputs (jq -r '.nodes.root.inputs | keys[]' $current_lock)

    for input in $inputs
        if test -z "$input"
            continue
        end

        # Get nodes for this input from both locks
        set -l current_nodes_raw (get_input_nodes $current_lock $input)
        set -l prev_nodes_raw (get_input_nodes $prev_lock $input)

        # Convert to arrays
        set -l current_nodes_arr
        set -l prev_nodes_arr

        if test -n "$current_nodes_raw"
            set current_nodes_arr (string split '\n' $current_nodes_raw)
        end

        if test -n "$prev_nodes_raw"
            set prev_nodes_arr (string split '\n' $prev_nodes_raw)
        end

        set -l total_nodes (count $current_nodes_arr)

        # Compare each node
        for i in (seq 1 $total_nodes)
            set -l curr_node $current_nodes_arr[$i]
            set -l prev_node ""

            if test $i -le (count $prev_nodes_arr)
                set prev_node $prev_nodes_arr[$i]
            end

            set -l current_rev (get_node_revision $current_lock $curr_node)
            set -l prev_rev ""

            if test -n "$prev_node"
                set prev_rev (get_node_revision $prev_lock $prev_node)
            end

            # Check if revision changed
            if test "$current_rev" != "$prev_rev" -a -n "$current_rev"
                set -l node_url (get_node_url $current_lock $curr_node)
                # Fixed: ensure all 7 parameters are passed correctly
                set -l formatted_entry (format_change_entry $input $curr_node $prev_rev $current_rev $node_url $i $total_nodes)
                set changed_entries $changed_entries $formatted_entry
            end
        end
    end

    rm -f $prev_lock

    if test (count $changed_entries) -eq 0
        return 1
    end

    printf '%s\n' $changed_entries
end

# Parse selection to get input name and node info
function parse_selection
    set -l selection $argv[1]

    # Extract input name (everything before the first space or #)
    set -l input_name (string replace -r '([^#\s]+).*' '$1' $selection)

    # Extract node key (hash) from brackets
    set -l node_name (string replace -r '.*\[(\w+)\].*' '$1' $selection)
    echo $node_name

    echo "$input_name|$node_name"
end

# Revert selected inputs with better error handling
function revert_inputs
    set -l flake_dir $argv[1]
    set -e argv[1]
    set -l selected_inputs $argv

    if test (count $selected_inputs) -eq 0
        echo "No inputs selected for reversion"
        return 0
    end

    set -l prev_lock (get_previous_lock $flake_dir)
    set -l new_lock (mktemp)
    cp "$flake_dir/flake.lock" $new_lock

    set -l reverted_count 0

    for selected in $selected_inputs
        set -l parsed (parse_selection $selected)
        set -l input_name (string split '|' $parsed)[1]
        set -l node_name (string split '|' $parsed)[2]

        echo "Reverting $input_name [$node_name]..."

        # Get node data from previous lock
        set -l node_data (jq --arg node "$node_name" '.nodes[$node]' $prev_lock)

        if test "$node_data" = null
            echo "$(set_color yellow) Warning: Could not find node $input_name in previous lock file$(set_color normal)"
            continue
        end

        # Update the new lock file
        if jq --arg node "$node_name" --argjson data "$node_data" '.nodes[$node] = $data' $new_lock >$new_lock.tmp
            mv $new_lock.tmp $new_lock
            set reverted_count (math $reverted_count + 1)
        else
            echo "$(set_color red) Error: Failed to update node $node_name$(set_color normal)"
        end
    end

    # Replace the current flake.lock with the updated one
    if test $reverted_count -gt 0
        cp $new_lock "$flake_dir/flake.lock"
        echo "$(set_color green) Successfully reverted $reverted_count input(s)$(set_color normal)"
    else
        echo "$(set_color yellow) No inputs were reverted$(set_color normal)"
    end

    # Clean up
    rm -f $prev_lock $new_lock
end

# Main function
function main
    set -l flake_dir "."
    if test (count $argv) -ge 1
        set flake_dir $argv[1]
    end

    check_prerequisites $flake_dir

    # Get changed inputs
    set -l changed_inputs_output (get_changed_inputs $flake_dir)
    set -l get_inputs_status $status

    if test $get_inputs_status -ne 0
        echo ""
        echo "$(set_color cyan) No changes detected in flake.lock$(set_color normal)"
        return 0
    end

    # Use fzf to select inputs to revert
    set -l selected_inputs (printf '%s\n' $changed_inputs_output | fzf --ansi --multi --header="󱄅  Select inputs to revert (Tab for multiple, Enter to confirm)" --prompt="󰏗  Input to revert: ")

    if test (count $selected_inputs) -eq 0
        echo "$(set_color yellow) No inputs selected. Exiting.$(set_color normal)"
        return 0
    end

    # Confirm the selection
    echo ""
    echo "You selected the following inputs to revert:"
    for input in $selected_inputs
        echo "  -$(set_color red)  $input$(set_color normal)"
    end
    echo ""

    read -P "Are you sure you want to revert these inputs? (y/N): " -n 1 confirm
    echo ""

    if not string match -qi 'y*' $confirm
        echo "$(set_color yellow) Operation cancelled.$(set_color normal)"
        return 0
    end

    # Revert the selected inputs
    revert_inputs $flake_dir $selected_inputs
end

# Run main function
main $argv
