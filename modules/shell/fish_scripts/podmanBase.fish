function setup_podman_base
    set desired_cpus $NIX_PODMAN_CPU
    set desired_memory $NIX_PODMAN_MEMORY
    set desired_rosetta $NIX_PODMAN_ROSETTA

    # Set defaults if variables aren't set
    test -z "$desired_cpus"; and set desired_cpus 4
    test -z "$desired_memory"; and set desired_memory 4096
    test -z "$desired_rosetta"; and set desired_rosetta true

    echo "Desired configuration: CPUs=$desired_cpus, Memory=$desired_memory MB, Rosetta=$desired_rosetta"

    # Track whether a single restart is needed at the end (e.g. Rosetta change)
    set needs_restart false

    if not podman machine ls --format '{{.Name}}' | grep -q podman-machine-default
        echo "No default podman machine found, initializing one..."
        podman machine init --cpus $desired_cpus --memory $desired_memory
    else
        set current_cpus (podman machine inspect podman-machine-default --format '{{.Resources.CPUs}}')
        set current_memory (podman machine inspect podman-machine-default --format '{{.Resources.Memory}}')
        echo "Current configuration: CPUs=$current_cpus, Memory=$current_memory MB"

        # CPU/memory can only change by recreating the machine.
        if test "$current_cpus" != "$desired_cpus"; or test "$current_memory" != "$desired_memory"
            echo "CPU/memory mismatch, recreating podman machine..."
            podman machine stop podman-machine-default 2>/dev/null
            podman machine rm -f podman-machine-default
            podman machine init --cpus $desired_cpus --memory $desired_memory
        end
    end

    if not podman machine ls --format '{{.Running}}' | grep -q true
        echo "Starting podman machine..."
        podman machine start podman-machine-default
    end

    # Reconcile Rosetta. Enabling means creating a file inside the VM, which
    # only takes effect after a restart — so we defer that to a single
    # restart at the end instead of cycling the machine separately.
    # https://blog.podman.io/2025/08/podman-5-6-released-rosetta-status-update/
    if test "$desired_rosetta" = true
        if podman machine ssh podman-machine-default "cat /proc/sys/fs/binfmt_misc/rosetta" 2>/dev/null | grep -q enabled
            echo "Rosetta: already enabled"
        else
            echo "Rosetta: enabling..."
            podman machine ssh podman-machine-default "sudo touch /etc/containers/enable-rosetta"
            set needs_restart true
        end
    end

    if test "$needs_restart" = true
        echo "Restarting podman machine to apply changes..."
        podman machine stop podman-machine-default
        podman machine start podman-machine-default

        if test "$desired_rosetta" = true
            if podman machine ssh podman-machine-default "cat /proc/sys/fs/binfmt_misc/rosetta" 2>/dev/null | grep -q enabled
                echo "Rosetta: enabled"
            else
                echo "Rosetta: failed to enable (check Podman version / provider)"
            end
        end
    end

    echo "Podman machine ready: CPUs=$desired_cpus, Memory=$desired_memory MB, Rosetta=$desired_rosetta"
end
