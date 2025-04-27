function setup_podman_base
    set desired_cpus $NIX_PODMAN_CPU
    set desired_memory $NIX_PODMAN_MEMORY

    # Set defaults if variables aren't set
    if test -z "$desired_cpus"
        set desired_cpus 4
    end

    if test -z "$desired_memory"
        set desired_memory 4096
    end

    # Check if default machine exists
    if not podman machine ls --format '{{.Name}}' | grep -q podman-machine-default
        echo "No default podman machine found, initializing one..."
        podman machine init --cpus $desired_cpus --memory $desired_memory
        podman machine start podman-machine-default
        return
    end

    # Get current configuration
    set current_cpus (podman machine inspect podman-machine-default --format '{{.Resources.CPUs}}')
    set current_memory (podman machine inspect podman-machine-default --format '{{.Resources.Memory}}')

    echo "Current configuration: CPUs=$current_cpus, Memory=$current_memory MB"
    echo "Desired configuration: CPUs=$desired_cpus, Memory=$desired_memory MB"

    # Check if reconfiguration is needed
    if test "$current_cpus" != "$desired_cpus"; or test "$current_memory" != "$desired_memory"
        echo "Reconfiguring podman machine..."

        # Stop and remove if running
        podman machine stop podman-machine-default 2>/dev/null
        podman machine rm -f podman-machine-default

        # Create new machine with desired configuration
        podman machine init --cpus $desired_cpus --memory $desired_memory
        podman machine start podman-machine-default
    else
        # Start if not running
        if not podman machine ls --format '{{.Running}}' | grep -q true
            echo "Starting podman machine..."
            podman machine start podman-machine-default
        else
            echo "Podman machine is already running with desired configuration."
        end
    end
end
