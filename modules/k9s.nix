{
  flake.modules.homeManager.base = {lib, ...}: {
    programs.k9s = {
      enable = lib.mkDefault true;
      settings = {
        k9s = {
          liveViewAutoRefresh = true;
          ui = {
            skin = "catppuccin-macchiato";
            enableMouse = true;
            reactive = true;
            logoless = true;
          };
          logger = {
            tail = 500;
            buffer = 5000;
            sinceSeconds = -1;
          };
        };
      };
      aliases = {
        cr = "clusterroles";
        crb = "clusterrolebindings";
        dp = "deployments";
        jo = "jobs";
        np = "networkpolicies";
        pp = "pods";
        rb = "rolebindings";
        ro = "roles";
        sec = "secrets";
      };
      views = {
        # Re-check against internal/render/pod.go on k9s upgrades.
        "v1/pods" = {
          columns = [
            "NAMESPACE"
            "NAME"
            "VS"
            "PF"
            "READY"
            "STATUS"
            "REASON:.status.reason"
            "RESTARTS"
            "LAST RESTART"
            "CPU"
            "CPU/RL"
            "%CPU/R"
            "%CPU/L"
            "MEM"
            "MEM/RL"
            "%MEM/R"
            "%MEM/L"
            "GPU/RL"
            "IP"
            "NODE"
            "SERVICE-ACCOUNT"
            "NOMINATED NODE"
            "READINESS GATES"
            "QOS"
            "LABELS"
            "VALID"
            "AGE"
          ];
        };
      };
      hotKeys = {
        shift-1 = {
          command = "pods";
          description = "View pods";
          shortCut = "Shift-1";
        };
        shift-2 = {
          command = "deployments";
          description = "View deployments";
          shortCut = "Shift-2";
        };
        shift-3 = {
          command = "statefulsets";
          description = "View statefulsets";
          shortCut = "Shift-3";
        };
        shift-4 = {
          command = "configmaps";
          description = "View configmaps";
          shortCut = "Shift-4";
        };
        shift-5 = {
          command = "secrets";
          description = "View secrets";
          shortCut = "Shift-5";
        };
        shift-6 = {
          command = "jobs";
          description = "View jobs";
          shortCut = "Shift-6";
        };
      };
    };
    home.file = {
      "Library/Application Support/k9s/skins/catppuccin-macchiato.yaml" = {
        source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/k9s/refs/heads/main/dist/catppuccin-macchiato.yaml";
          sha256 = "1wdxway40xzz0kl4phs64h0h9b4xvkgsh7c75w0s9za8az6bf79r";
        };
        force = true;
      };
    };
  };
}
