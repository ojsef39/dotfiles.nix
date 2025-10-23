{
  pkgs,
  vars,
}: let
  # Image configuration from vars
  inherit (vars.kubectl-debug) imageName;
  imageTag = vars.kubectl-debug.imageTag or "latest";
  username = vars.user.name;

  # Import nixpkgs for x86_64-linux to build the Docker image with the Linux builder
  linuxPkgs = import pkgs.path {system = "x86_64-linux";};

  # Build layered image - each package gets its own layer for better caching
  kubectl-debug-image = linuxPkgs.dockerTools.buildLayeredImage {
    name = imageName;
    tag = imageTag;
    architecture = "amd64";

    # Each package will be in its own layer (better Docker cache utilization)
    contents = with linuxPkgs; [
      bash
      coreutils
      dnsutils # nslookup, dig
      curl
      wget
      iputils # ping
      netcat
      traceroute
      iproute2 # ip, ss, etc.
      tcpdump
      vim
    ];

    config = {
      Cmd = ["/bin/bash"];
      User = "1000:1000";
    };
  };
in
  pkgs.writeShellApplication {
    name = "kubectl-debug";

    runtimeInputs = with pkgs; [
      kubectl
      podman
    ];

    text = ''
      set -euo pipefail

      FULL_IMAGE="${imageName}:${imageTag}"
      IMAGE_TARBALL="${kubectl-debug-image}"

      # Colors for output
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      NC='\033[0m' # No Color

      log_info() {
        echo -e "''${GREEN}[kubectl-debug]''${NC} $*"
      }

      log_warn() {
        echo -e "''${YELLOW}[kubectl-debug]''${NC} $*"
      }

      log_error() {
        echo -e "''${RED}[kubectl-debug]''${NC} $*" >&2
      }

      usage() {
        cat <<EOF
      Usage: kubectl-debug [OPTIONS] <namespace> [attach <pod-name>]

      A debugging tool that loads and pushes a Nix-built debug container to Kubernetes.

      Commands:
        kubectl-debug <namespace>                    Start an interactive debug pod with --rm -it
        kubectl-debug <namespace> attach <pod-name>  Attach a debug container to an existing pod

      Options:
        -h, --help                Show this help message
        --skip-push               Skip pushing the Docker image
        --force-push              Force push even if image exists in registry

      Examples:
        # Start interactive debug pod in namespace 'dev'
        kubectl-debug dev

        # Attach debug container to existing pod
        kubectl-debug dev attach my-pod-name

      The debug image is built with Nix and includes:
        - bash, coreutils
        - dnsutils (nslookup, dig)
        - curl, wget
        - ping, traceroute, netcat
        - tcpdump, iproute2, vim

      EOF
        exit 0
      }

      check_image_needs_push() {
        log_info "Checking if image needs to be pushed..."

        # Get local image digest
        local local_digest
        local_digest=$(podman image inspect "$FULL_IMAGE" --format '{{.Digest}}' 2>/dev/null || echo "")

        if [ -z "$local_digest" ]; then
          log_warn "Local image not loaded yet, will push"
          return 0  # Needs push
        fi

        # Try to get remote image digest
        local remote_digest
        remote_digest=$(podman manifest inspect "$FULL_IMAGE" --format '{{.Digest}}' 2>/dev/null || echo "")

        if [ -z "$remote_digest" ]; then
          log_info "Image does not exist in registry, will push"
          return 0  # Needs push
        fi

        # Compare digests
        if [ "$local_digest" = "$remote_digest" ]; then
          log_info "Image already exists with same digest ($local_digest)"
          return 1  # Does not need push
        else
          log_info "Image exists but digest differs (local: $local_digest, remote: $remote_digest)"
          return 0  # Needs push
        fi
      }

      load_and_push_image() {
        log_info "Loading Nix-built image..."
        podman load < "$IMAGE_TARBALL"

        log_info "Tagging image as $FULL_IMAGE..."
        podman tag "$FULL_IMAGE" "$FULL_IMAGE" 2>/dev/null || true

        log_info "Pushing image to registry..."
        podman push "$FULL_IMAGE"
      }

      run_interactive() {
        local namespace=$1
        log_info "Starting interactive debug pod in namespace '$namespace'..."
        kubectl run ${username}-debug-temp \
          --rm -it \
          --namespace="$namespace" \
          --image="$FULL_IMAGE" \
          --image-pull-policy=Always \
          -- /bin/bash
      }

      attach_to_pod() {
        local namespace=$1
        local pod_name=$2
        log_info "Attaching debug container to pod '$pod_name' in namespace '$namespace'..."

        # Get the first container name
        local container_name
        container_name=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.spec.containers[0].name}')

        kubectl debug "$pod_name" \
          --namespace="$namespace" \
          -it \
          --image="$FULL_IMAGE" \
          --image-pull-policy=Always \
          --target="$container_name"
      }

      # Parse options
      SKIP_PUSH=false
      FORCE_PUSH=false

      while [[ $# -gt 0 ]]; do
        case $1 in
          -h|--help)
            usage
            ;;
          --skip-push)
            SKIP_PUSH=true
            shift
            ;;
          --force-push)
            FORCE_PUSH=true
            shift
            ;;
          -*)
            log_error "Unknown option: $1"
            usage
            ;;
          *)
            break
            ;;
        esac
      done

      # Check arguments
      if [[ $# -lt 1 ]]; then
        log_error "Missing required argument: namespace"
        usage
      fi

      NAMESPACE=$1
      MODE="interactive"
      POD_NAME=""

      if [[ $# -ge 2 ]]; then
        if [[ $2 == "attach" ]]; then
          if [[ $# -lt 3 ]]; then
            log_error "Missing pod name for attach command"
            usage
          fi
          MODE="attach"
          POD_NAME=$3
        else
          log_error "Unknown command: $2"
          usage
        fi
      fi

      # Push logic
      if [[ "$SKIP_PUSH" == "false" ]]; then
        if [[ "$FORCE_PUSH" == "true" ]] || check_image_needs_push; then
          load_and_push_image
        else
          log_info "Image is up to date in registry, skipping push"
          log_info "Use --force-push to push anyway"
        fi
      else
        log_warn "Skipping push (--skip-push specified)"
      fi

      # Run the appropriate command
      if [[ "$MODE" == "interactive" ]]; then
        run_interactive "$NAMESPACE"
      else
        attach_to_pod "$NAMESPACE" "$POD_NAME"
      fi
    '';
  }
