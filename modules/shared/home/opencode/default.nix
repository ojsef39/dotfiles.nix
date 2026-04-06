{lib, ...}: let
  modelOptions = {
    reasoningEffort = "high";
    textVerbosity = "low";
    thinking = {
      type = "enabled";
    };
  };
in {
  home.sessionVariables = {
    OPENCODE_ENABLE_EXA = "1"; # enables https://opencode.ai/docs/de/tools/#websearch
  };

  programs.opencode = {
    enable = true;
    tui = {
      theme = "catppuccin";
    };
    settings = {
      model = lib.mkDefault "github/claude-sonnet-4-6";
      small_model = lib.mkDefault "github/claude-haiku-4-5";
      autoupdate = false;
      disabled_providers = ["xai"];
      permission = {
        websearch = "allow";
        webfetch = "allow";
        bash = {
          pwd = "allow";
          "git status" = "allow";
          "*" = "ask";
        };
      };

      agent = {
        build = {
          model = "github-copilot/claude-sonnet-4.6";
          options =
            {
              textVerbosity = "low";
            }
            // modelOptions;
        };
        plan = {
          # model = "github-copilot/claude-opus-4.6";
          model = "github-copilot/claude-sonnet-4.6";
          options = modelOptions;
        };
        code-reviewer = {
          description = "Reviews code for best practices and potential issues";
          mode = "subagent";
          model = "github-copilot/claude-sonnet-4.6";
          prompt = "You are a code reviewer. Focus on security, performance, and maintainability.";
          tools = {
            write = false;
            edit = false;
          };
        };
      };

      # LSP Configuration
      lsp = {
        # Custom LSP servers (opencode has built-in support for most, but we ensure they use nix)
        gopls = {
          command = [
            "nix-shell"
            "--pure"
            "-p"
            "gopls"
            "--run"
            "gopls"
          ];
          extensions = [".go"];
        };
        nixd = {
          command = ["nixd"];
          extensions = [".nix"];
        };
      };

      # Formatter Configuration
      formatter = {
        # JavaScript/TypeScript/JSON/YAML/CSS/HTML/Markdown
        prettier = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#prettier"
            "--"
            "--write"
            "$FILE"
          ];
          extensions = [
            ".js"
            ".ts"
            ".jsx"
            ".tsx"
            ".json"
            ".json5"
            ".jsonc"
            ".yaml"
            ".yml"
            ".css"
            ".scss"
            ".less"
            ".html"
            ".md"
            ".mdx"
            ".graphql"
            ".vue"
          ];
        };
        "markdownlint-cli2" = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#markdownlint-cli2"
            "--"
            "$FILE"
          ];
          extensions = [
            ".md"
            ".mdx"
          ];
        };

        # Nix
        alejandra = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#alejandra"
            "--"
            "$FILE"
          ];
          extensions = [".nix"];
        };

        # Lua
        stylua = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#stylua"
            "--"
            "-"
            "$FILE"
          ];
          extensions = [".lua"];
        };

        # Go
        gofumpt = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#gofumpt"
            "--"
            "-w"
            "$FILE"
          ];
          extensions = [".go"];
        };
        "goimports-reviser" = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#goimports-reviser"
            "--"
            "$FILE"
          ];
          extensions = [".go"];
        };

        # Python
        black = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#python3Packages.black"
            "--"
            "$FILE"
          ];
          extensions = [".py"];
        };

        # Rust
        rustfmt = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#rustfmt"
            "--"
            "$FILE"
          ];
          extensions = [".rs"];
        };

        # Shell
        shfmt = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#shfmt"
            "--"
            "-i"
            "2"
            "-w"
            "$FILE"
          ];
          extensions = [
            ".sh"
            ".bash"
          ];
        };

        # Terraform
        terraform_fmt = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#terraform"
            "--"
            "fmt"
            "-"
          ];
          extensions = [
            ".tf"
            ".tfvars"
          ];
          environment = {
            NIXPKGS_ALLOW_UNFREE = "1";
          };
        };

        # Fish
        fish_indent = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#fish"
            "--"
            "fish_indent"
          ];
          extensions = [".fish"];
        };

        # Swift
        swift-format = {
          command = [
            "nix"
            "run"
            "--impure"
            "nixpkgs#swift-format"
            "--"
            "$FILE"
          ];
          extensions = [".swift"];
        };
      };
    };
  };
}
