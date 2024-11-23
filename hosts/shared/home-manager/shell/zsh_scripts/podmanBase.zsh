setup_podman_base() {
  if ! podman machine ls --format "{{.Name}}" | grep -q "podman-machine-default"; then
    echo "No default podman machine found, initializing one..."
    podman  machine init
  fi
  if ! podman machine ls --format "{{.Running}}" | grep -q "true"; then
    podman machine start
  else
    echo "Default podman machine is already running."
  fi
}
