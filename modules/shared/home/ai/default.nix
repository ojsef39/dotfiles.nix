{
  lib,
  pkgs,
  ...
}: let
  instructionsDir = ./instructions;
in {
  imports = [
    ./mcp.nix
    ./claude-code.nix
    ./copilot.nix
    ./opencode.nix
  ];

  _module.args.ai = {
    model = "claude-sonnet-4.6";
    effortLevel = "high";
    inherit instructionsDir;

    # Bash glob patterns allowed across all AI tools (without prompting)
    # Format: opencode-style globs — "cmd" for exact match, "cmd *" for any args.
    # Wrapped as Bash(<pattern>) in claude-code, used as-is in opencode.
    allowedBashCommands = [
      "gh run watch *"
      "git status"
      "pwd"
      "send-away *"
      "send-cooking"
    ];

    # Domains allowed across all AI tools
    # Used as WebFetch(domain:X) in claude-code, https://X in copilot
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

    # MCP tool calls allowed across all AI tools (without prompting)
    # NOTE: opencode has no permission system yet for MCPs
    # NOTE: copilot has no documentation on this
    allowedMcpTools = let
      gh = "mcp__plugin_claude-code-home-manager_github-mcp-server";
    in [
      "${gh}__get_me"
      "${gh}__get_file_contents"
      "${gh}__get_repository_tree"
      "${gh}__list_issues"
      "${gh}__issue_read"
      "${gh}__search_issues"
      "${gh}__list_pull_requests"
      "${gh}__pull_request_read"
      "${gh}__search_pull_requests"
      "${gh}__list_branches"
      "${gh}__list_commits"
      "${gh}__get_commit"
      "${gh}__search_code"
      "${gh}__search_repositories"
      "${gh}__list_releases"
      "${gh}__get_latest_release"
      "${gh}__list_tags"
      "${gh}__get_tag"
      "${gh}__actions_list"
      "${gh}__actions_get"
      "${gh}__get_job_logs"
      "${gh}__list_label"
      "${gh}__get_label"
      "${gh}__list_notifications"
      "${gh}__get_notification_details"
      "${gh}__list_discussions"
      "${gh}__get_discussion"
      "${gh}__get_discussion_comments"
      "${gh}__list_discussion_categories"
      "${gh}__projects_list"
      "${gh}__projects_get"
    ];

    # Shared LSP definitions — consumed by opencode, copilot, and claude-code via transformers
    lspServers = lib.filter (s: s.enable) [
      {
        enable = true;
        name = "go";
        command = "${pkgs.gopls}/bin/gopls";
        args = ["serve"];
        extensions = [".go"];
        languageIds = {".go" = "go";};
      }
      {
        enable = true;
        name = "nix";
        command = "${pkgs.nixd}/bin/nixd";
        args = [];
        extensions = [".nix"];
        languageIds = {".nix" = "nix";};
      }
      {
        enable = true;
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
        enable = true;
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
        enable = true;
        name = "rust";
        command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        args = [];
        extensions = [".rs"];
        languageIds = {".rs" = "rust";};
      }
      {
        enable = true;
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
        enable = true;
        name = "lua";
        command = "${pkgs.lua-language-server}/bin/lua-language-server";
        args = [];
        extensions = [".lua"];
        languageIds = {".lua" = "lua";};
      }
      {
        enable = true;
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
        enable = true;
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
        enable = true;
        name = "clangd";
        command = "${pkgs.clang-tools}/bin/clangd";
        args = [];
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
        enable = true;
        name = "jsonls";
        command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
        args = ["--stdio"];
        extensions = [".json" ".jsonc"];
        languageIds = {
          ".json" = "json";
          ".jsonc" = "jsonc";
        };
      }
      {
        enable = pkgs.stdenv.isDarwin;
        name = "sourcekit";
        command = "${pkgs.sourcekit-lsp}/bin/sourcekit-lsp";
        args = [];
        extensions = [".swift"];
        languageIds = {".swift" = "swift";};
      }
    ];
  };
}
