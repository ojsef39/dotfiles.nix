setup_podman_base() {
  desired_cpus=${NIX_PODMAN_CPU:-4}
  desired_memory=${NIX_PODMAN_MEMORY:-4096}

  # Check if default machine exists
  if ! podman machine ls --format '{{.Name}}' | grep -q "podman-machine-default"; then
    echo "No default podman machine found, initializing one..."
    podman machine init --cpus $desired_cpus --memory $desired_memory
    podman machine start podman-machine-default
    return
  fi

  # Get current configuration
  current_cpus=$(podman machine inspect podman-machine-default --format '{{.Resources.CPUs}}')
  current_memory=$(podman machine inspect podman-machine-default --format '{{.Resources.Memory}}')

  echo "Current configuration: CPUs=$current_cpus, Memory=${current_memory}MB"
  echo "Desired configuration: CPUs=$desired_cpus, Memory=${desired_memory}MB"

  # Check if reconfiguration is needed
  if [ "$current_cpus" != "$desired_cpus" ] || [ "$current_memory" != "$desired_memory" ]; then
    echo "Reconfiguring podman machine..."

    # Stop and remove if running
    podman machine stop podman-machine-default 2>/dev/null
    podman machine rm -f podman-machine-default

    # Create new machine with desired configuration
    podman machine init --cpus $desired_cpus --memory $desired_memory
    podman machine start podman-machine-default
  else
    # Start if not running
    if ! podman machine ls --format '{{.Running}}' | grep -q "true"; then
      echo "Starting podman machine..."
      podman machine start podman-machine-default
    else
      echo "Podman machine is already running with desired configuration."
    fi
  fi
}
