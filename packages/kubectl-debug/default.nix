{
  pkgs,
  vars,
}: let
  # Image configuration from vars
  imageName = vars.kubectl-debug.imageName or (throw "vars.kubectl-debug.imageName must be set");
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

  # Fish completion script
  kubectl-debug-fishCompletion = pkgs.writeText "kubectl-debug.fish" ''
    # kubectl-debug completions for Fish shell

    # Helper function to get namespaces
    function __kubectl_debug_get_namespaces
      kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | string split ' '
    end

    # Helper function to get pods in a namespace
    function __kubectl_debug_get_pods
      set -l namespace (commandline -opc | string match -r -- '--namespace[= ](\\S+)' | string replace -r '.*[= ]' "")
      if test -z "$namespace"
        # Try to find namespace as positional argument
        set namespace (commandline -opc)[2]
      end
      if test -n "$namespace"
        kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | string split ' '
      end
    end

    # Check if --attach flag has been used
    function __kubectl_debug_using_attach
      commandline -opc | string match -q -- '--attach*'
    end

    # Complete kubectl-debug
    complete -c kubectl-debug -f

    # Script-specific flags
    complete -c kubectl-debug -l help -s h -d "Show help message"
    complete -c kubectl-debug -l skip-push -d "Skip pushing the Docker image"
    complete -c kubectl-debug -l force-push -d "Force push even if image exists in registry"
    complete -c kubectl-debug -l attach -d "Attach debug container to existing pod" -xa '(__kubectl_debug_get_pods)'
    complete -c kubectl-debug -l labels -d "Pod labels as comma-separated key=value pairs"

    # Namespace completion (first positional argument)
    complete -c kubectl-debug -n "__fish_is_nth_token 1" -xa '(__kubectl_debug_get_namespaces)'

    # kubectl run flags (when NOT using --attach)
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l restart -d "Restart policy (Always, OnFailure, Never)" -xa "Always OnFailure Never"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l env -d "Environment variables to set"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l command -d "Use command instead of default entrypoint"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l port -d "Port to expose"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l expose -d "Expose the pod as a service"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l service-account -d "Service account to use"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l limits -d "Resource limits"
    complete -c kubectl-debug -n "not __kubectl_debug_using_attach" -l requests -d "Resource requests"

    # kubectl debug flags (when using --attach)
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l target -d "Target container name"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l container -d "Container name for debug container"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l share-processes -d "Share process namespace with container" -xa "true false"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l copy-to -d "Copy the pod and attach to the copy"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l replace -d "Delete and recreate the resource"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l same-node -d "Schedule on the same node"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l set-image -d "Set image for container"
    complete -c kubectl-debug -n "__kubectl_debug_using_attach" -l env -d "Environment variables to set"
  '';

  # Main script
  scriptApp = pkgs.writeShellApplication {
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
      Usage: kubectl-debug [OPTIONS] <namespace>

      A debugging tool that loads and pushes a Nix-built debug container to Kubernetes.

      The image is always loaded and pushed to the registry. Docker's layer caching
      ensures that only changed layers are uploaded, making subsequent pushes fast.

      Options:
        -h, --help                Show this help message
        --skip-push               Skip pushing the Docker image (use local only)
        --attach <pod-name>       Attach a debug container to an existing pod
        --labels <key=val,...>    Pod labels as comma-separated key=value pairs

      Any other flags are passed through to kubectl run/debug commands.

      Examples:
        # Start interactive debug pod in namespace 'dev'
        kubectl-debug dev

        # Attach debug container to existing pod
        kubectl-debug dev --attach my-pod-name

        # With custom labels
        kubectl-debug dev --labels env=debug,app=troubleshoot

        # Pass through kubectl flags
        kubectl-debug dev --attach my-pod --share-processes --container=mycontainer

        # Skip push (use only if image is already in registry)
        kubectl-debug dev --skip-push

      The debug image is built with Nix and includes:
        - bash, coreutils
        - dnsutils (nslookup, dig)
        - curl, wget
        - ping, traceroute, netcat
        - tcpdump, iproute2, vim

      EOF
        exit 0
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
        shift
        local extra_args=("$@")

        log_info "Starting interactive debug pod in namespace '$namespace'..."
        kubectl run ${username}-debug-temp \
          --rm -it \
          --namespace="$namespace" \
          --image="$FULL_IMAGE" \
          --image-pull-policy=Always \
          "''${extra_args[@]}" \
          -- /bin/bash
      }

      attach_to_pod() {
        local namespace=$1
        local pod_name=$2
        shift 2
        local extra_args=("$@")

        log_info "Attaching debug container to pod '$pod_name' in namespace '$namespace'..."

        # Get the first container name if --target is not specified
        local has_target=false
        for arg in "''${extra_args[@]}"; do
          if [[ "$arg" == --target* ]]; then
            has_target=true
            break
          fi
        done

        if [[ "$has_target" == "false" ]]; then
          local container_name
          container_name=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.spec.containers[0].name}')
          extra_args+=("--target=$container_name")
        fi

        kubectl debug "$pod_name" \
          --namespace="$namespace" \
          -it \
          --image="$FULL_IMAGE" \
          --image-pull-policy=Always \
          "''${extra_args[@]}"
      }

      # Parse options
      SKIP_PUSH=false
      MODE="interactive"
      POD_NAME=""
      POD_LABELS=""
      NAMESPACE=""
      KUBECTL_EXTRA_ARGS=()

      # First pass: collect all arguments
      while [[ $# -gt 0 ]]; do
        case $1 in
          -h|--help)
            usage
            ;;
          --skip-push)
            SKIP_PUSH=true
            shift
            ;;
          --attach)
            MODE="attach"
            if [[ $# -lt 2 ]]; then
              log_error "Missing pod name for --attach"
              usage
            fi
            POD_NAME=$2
            shift 2
            ;;
          --labels)
            if [[ $# -lt 2 ]]; then
              log_error "Missing value for --labels"
              usage
            fi
            POD_LABELS=$2
            shift 2
            ;;
          -*)
            # Pass through any other flags to kubectl
            KUBECTL_EXTRA_ARGS+=("$1")
            # Check if this flag takes a value (has = or next arg doesn't start with -)
            if [[ "$1" != *=* && $# -gt 1 && "$2" != -* ]]; then
              KUBECTL_EXTRA_ARGS+=("$2")
              shift
            fi
            shift
            ;;
          *)
            # This is the namespace (positional argument)
            if [[ -z "$NAMESPACE" ]]; then
              NAMESPACE=$1
              shift
            else
              log_error "Unexpected argument: $1"
              usage
            fi
            ;;
        esac
      done

      # Check namespace was provided
      if [[ -z "$NAMESPACE" ]]; then
        log_error "Missing required argument: namespace"
        usage
      fi

      # Validate attach mode
      if [[ "$MODE" == "attach" && -z "$POD_NAME" ]]; then
        log_error "Missing pod name for --attach"
        usage
      fi

      # Add labels to kubectl args if specified
      if [[ -n "$POD_LABELS" ]]; then
        # Convert comma-separated labels to kubectl format
        KUBECTL_EXTRA_ARGS+=("--labels=$POD_LABELS")
      fi

      # Push logic
      if [[ "$SKIP_PUSH" == "false" ]]; then
        load_and_push_image
      else
        log_warn "Skipping push (--skip-push specified)"
      fi

      # Run the appropriate command
      if [[ "$MODE" == "interactive" ]]; then
        run_interactive "$NAMESPACE" "''${KUBECTL_EXTRA_ARGS[@]}"
      else
        attach_to_pod "$NAMESPACE" "$POD_NAME" "''${KUBECTL_EXTRA_ARGS[@]}"
      fi
    '';
  };
in
  # Wrap the script with completions
  pkgs.symlinkJoin {
    name = "kubectl-debug";
    paths = [scriptApp];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      mkdir -p $out/share/fish/vendor_completions.d
      cp ${kubectl-debug-fishCompletion} $out/share/fish/vendor_completions.d/kubectl-debug.fish
    '';
  }
