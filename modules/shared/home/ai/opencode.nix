{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai;
  # opencode uses dashes and a provider prefix: "github/claude-sonnet-4-6"
  opencodeModel = "github/${builtins.replaceStrings ["."] ["-"] cfg.model}";
  modelOptions = {
    reasoningEffort = cfg.effortLevel;
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
    enableMcpIntegration = true;
    tui = {
      theme = "catppuccin";
    };
    settings = {
      model = lib.mkDefault opencodeModel;
      instructions = ["${cfg.instructionsDir}/*.md"];
      autoupdate = false;
      disabled_providers = ["xai"];
      permission = {
        websearch = "allow";
        webfetch = "allow";
        bash =
          {
            "*" = "ask";
          }
          // builtins.listToAttrs (map (p: {
              name = p;
              value = "allow";
            })
            cfg.allowedBashCommands);
      };

      agent = {
        build = {
          model = "github-copilot/${cfg.model}";
          options =
            {
              textVerbosity = "low";
            }
            // modelOptions;
        };
        plan = {
          # model = "github-copilot/claude-opus-4.6";
          model = "github-copilot/${cfg.model}";
          options = modelOptions;
        };
        code-reviewer = {
          description = "Reviews code for best practices and potential issues";
          mode = "subagent";
          model = "github-copilot/${cfg.model}";
          prompt = "You are a code reviewer. Focus on security, performance, and maintainability.";
          tools = {
            write = false;
            edit = false;
          };
        };
      };

      # LSP Configuration
      lsp = builtins.listToAttrs (map (s: {
          inherit (s) name;
          value = {
            command = [s.command] ++ s.args;
            inherit (s) extensions;
          };
        })
        cfg.lspServers);

      # Formatter Configuration
      formatter = {
        # JavaScript/TypeScript/JSON/YAML/CSS/HTML/Markdown
        prettier = {
          command = [
            "${pkgs.prettier}/bin/prettier"
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
            "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2"
            "$FILE"
          ];
          extensions = [
            ".md"
            ".mdx"
          ];
        };

        # Nix
        nixfmt.disabled = true;
        alejandra = {
          command = [
            "${pkgs.alejandra}/bin/alejandra"
            "$FILE"
          ];
          extensions = [".nix"];
        };

        # Lua
        stylua = {
          command = [
            "${pkgs.stylua}/bin/stylua"
            "-"
            "$FILE"
          ];
          extensions = [".lua"];
        };

        # Go
        gofmt = {
          disabled = true;
        };
        gofumpt = {
          command = [
            "${pkgs.gofumpt}/bin/gofumpt"
            "-w"
            "$FILE"
          ];
          extensions = [".go"];
        };
        "goimports-reviser" = {
          command = [
            "${pkgs.goimports-reviser}/bin/goimports-reviser"
            "$FILE"
          ];
          extensions = [".go"];
        };

        # Python
        ruff = {
          command = [
            "${pkgs.ruff}/bin/ruff"
            "format"
            "$FILE"
          ];
          extensions = [".py"];
        };

        # Rust
        rustfmt = {
          command = [
            "${pkgs.rustfmt}/bin/rustfmt"
            "$FILE"
          ];
          extensions = [".rs"];
        };

        # Shell
        shfmt = {
          command = [
            "${pkgs.shfmt}/bin/shfmt"
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
        terraform = {
          command = [
            "${pkgs.opentofu}/bin/tofu"
            "fmt"
            "$FILE"
          ];
          extensions = [
            ".tf"
            ".tfvars"
          ];
        };

        # Fish
        fish_indent = {
          command = [
            "${pkgs.fish}/bin/fish_indent"
            "--write"
            "$FILE"
          ];
          extensions = [".fish"];
        };

        # Swift
        swift-format = {
          command = [
            "${pkgs.swift-format}/bin/swift-format"
            "$FILE"
          ];
          extensions = [".swift"];
        };
      };
    };
  };
}
