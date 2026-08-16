{
  flake.modules.homeManager.base = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.ai;
  in {
    options.ai = {
      model = lib.mkOption {
        type = lib.types.str;
        default = "claude-sonnet-5";
      };

      effortLevel = lib.mkOption {
        type = lib.types.str;
        default = "high";
      };

      instructionsDir = lib.mkOption {
        type = lib.types.path;
      };

      # Feature modules append directories of additional `*.instructions.md`
      # files here; default.nix merges them into instructionsDir.
      extraInstructionsDirs = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
      };

      # Bash glob patterns allowed across all AI tools (without prompting).
      # Format: opencode-style globs — "cmd" for exact match, "cmd *" for any args.
      # Wrapped as Bash(<pattern>) in claude-code, used as-is in opencode.
      allowedBashCommands = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      # Domains allowed across all AI tools.
      # Used as WebFetch(domain:X) in claude-code, https://X in copilot.
      allowedDomains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      # Keys are server names from programs.mcp.servers; values are tool names without
      # any tool-specific prefix. Each AI tool's config applies its own prefix format.
      # NOTE: copilot has no documentation on this
      allowedMcpCalls = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {};
      };

      # Shared LSP server definitions consumed by opencode, copilot, and claude-code.
      lspServers = lib.mkOption {
        default = [];
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {type = lib.types.str;};
            command = lib.mkOption {type = lib.types.str;};
            args = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
            };
            extensions = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
            };
            languageIds = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
            };
          };
        });
      };
    };

    config.ai = {
      instructionsDir = pkgs.symlinkJoin {
        name = "ai-instructions";
        paths = [./instructions] ++ cfg.extraInstructionsDirs;
      };

      allowedBashCommands = [
        "gh run watch *"
        "git status"
        "pwd"
        "send-away *"
        "send-cooking"
      ];

      allowedDomains = [
        "docs.github.com"
        "github.com"
        "home-manager.gitlab.io"
        "nix-community.github.io"
        "nix.dev"
        "nixos.org"
        "nixos.wiki"
        "patch-diff.githubusercontent.com"
        "raw.githubusercontent.com"
      ];

      allowedMcpCalls = {
        "github-mcp-server" = [
          "get_me"
          "get_file_contents"
          "get_repository_tree"
          "list_issues"
          "issue_read"
          "search_issues"
          "list_pull_requests"
          "pull_request_read"
          "search_pull_requests"
          "list_branches"
          "list_commits"
          "get_commit"
          "search_code"
          "search_repositories"
          "list_releases"
          "get_latest_release"
          "list_tags"
          "get_tag"
          "actions_list"
          "actions_get"
          "get_job_logs"
          "list_label"
          "get_label"
          "list_notifications"
          "get_notification_details"
          "list_discussions"
          "get_discussion"
          "get_discussion_comments"
          "list_discussion_categories"
          "projects_list"
          "projects_get"
        ];
        "io.github.upstash/context7" = [
          "resolve-library-id"
          "query-docs"
        ];
        "@exa" = [
          "web_search_exa"
          "web_fetch_exa"
        ];
      };

      lspServers =
        [
          {
            name = "go";
            command = "${pkgs.gopls}/bin/gopls";
            args = ["serve"];
            extensions = [".go"];
            languageIds = {".go" = "go";};
          }
          {
            name = "nix";
            command = "${pkgs.nixd}/bin/nixd";
            extensions = [".nix"];
            languageIds = {".nix" = "nix";};
          }
          {
            name = "typescript";
            command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
            args = ["--stdio"];
            extensions = [".ts" ".tsx" ".js" ".jsx" ".mjs" ".cjs" ".mts" ".cts"];
            languageIds = {
              ".ts" = "typescript";
              ".tsx" = "typescriptreact";
              ".js" = "javascript";
              ".jsx" = "javascriptreact";
              ".mjs" = "javascript";
              ".cjs" = "javascript";
              ".mts" = "typescript";
              ".cts" = "typescript";
            };
          }
          {
            name = "python";
            command = "${pkgs.pyright}/bin/pyright-langserver";
            args = ["--stdio"];
            extensions = [".py" ".pyw" ".pyi"];
            languageIds = {
              ".py" = "python";
              ".pyw" = "python";
              ".pyi" = "python";
            };
          }
          {
            name = "rust";
            command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            extensions = [".rs"];
            languageIds = {".rs" = "rust";};
          }
          {
            name = "bash";
            command = "${pkgs.bash-language-server}/bin/bash-language-server";
            args = ["start"];
            extensions = [".sh" ".bash"];
            languageIds = {
              ".sh" = "shellscript";
              ".bash" = "shellscript";
            };
          }
          {
            name = "lua";
            command = "${pkgs.lua-language-server}/bin/lua-language-server";
            extensions = [".lua"];
            languageIds = {".lua" = "lua";};
          }
          {
            name = "yaml";
            command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
            args = ["--stdio"];
            extensions = [".yaml" ".yml"];
            languageIds = {
              ".yaml" = "yaml";
              ".yml" = "yaml";
            };
          }
          {
            name = "terraform";
            command = "${pkgs.tofu-ls}/bin/tofu-ls";
            args = ["serve"];
            extensions = [".tf" ".tfvars"];
            languageIds = {
              ".tf" = "terraform";
              ".tfvars" = "terraform-vars";
            };
          }
          {
            name = "clangd";
            command = "${pkgs.clang-tools}/bin/clangd";
            extensions = [".c" ".cc" ".cpp" ".cxx" ".h" ".hh" ".hpp"];
            languageIds = {
              ".c" = "c";
              ".cc" = "cpp";
              ".cpp" = "cpp";
              ".cxx" = "cpp";
              ".h" = "c";
              ".hh" = "cpp";
              ".hpp" = "cpp";
            };
          }
          {
            name = "jsonls";
            command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
            args = ["--stdio"];
            extensions = [".json" ".jsonc"];
            languageIds = {
              ".json" = "json";
              ".jsonc" = "jsonc";
            };
          }
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [
          {
            name = "sourcekit";
            command = "${pkgs.sourcekit-lsp}/bin/sourcekit-lsp";
            extensions = [".swift"];
            languageIds = {".swift" = "swift";};
          }
        ];
    };
  };
}
