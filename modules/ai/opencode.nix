{
  flake.modules.homeManager.personal = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.ai;
    # V2 agents take effort as a model variant: "provider/model#variant".
    # Agent `request.body` is NOT sent to the model in V2, so V1-style agent
    # `options` (effort/thinking/textVerbosity) would silently do nothing.
    opencodeModel = "github-copilot/${cfg.model}";
    agentModel = "${opencodeModel}#${cfg.effortLevel}";

    rule = action: resource: effect: {inherit action resource effect;};

    # opencode names each MCP tool `<sanitize(server)>_<sanitize(tool)>` and looks
    # up that exact string in the permission ruleset. `sanitize` in
    # packages/core/src/tool/mcp.ts replaces every char outside [a-zA-Z0-9_-]
    # with `_`, so mirror that here.
    sanitize = s: let
      isAllowed = c: builtins.match "[a-zA-Z0-9_-]" c != null;
    in
      builtins.concatStringsSep "" (map (c:
        if isAllowed c
        then c
        else "_") (lib.stringToCharacters s));

    expandMcpCalls = calls:
      lib.flatten (lib.mapAttrsToList (server: tools:
        map (tool: rule "${sanitize server}_${sanitize tool}" "*" "allow") tools)
      calls);

    # Same shape home-manager's opencode module writes for programs.mcp.servers.
    toOpencodeMcp = s:
      if s ? url
      then
        {
          type = "remote";
          inherit (s) url;
        }
        // lib.optionalAttrs (s ? headers) {inherit (s) headers;}
      else
        {
          type = "local";
          command = [s.command] ++ (s.args or []);
        }
        // lib.optionalAttrs (s ? env) {environment = s.env;};
  in {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      # Check the generated config files against the package's own schemas at build time.
      validateFiles = {
        config = true;
        cli = true;
      };

      # CLI settings, written to cli.json (separate from the server config above).
      # Disable copy-on-select so mouse selection doesn't clobber the clipboard.
      cli = {
        terminal.copy = "manual";
      };

      # Native V2 config shape (https://opencode.ai/v2/docs/migrate-v1).
      settings = {
        model = lib.mkDefault opencodeModel;
        mcp = lib.mapAttrs (_: toOpencodeMcp) cfg.mcpPartialServers.opencode;
        instructions = ["${cfg.instructionsDir}/*.md"];
        update = "disable";
        policies = [(rule "provider.use" "xai" "deny")];
        # Exa works keyless (EXA_API_KEY optional); pinning it skips the first-search provider prompt.
        websearch.provider = "exa";

        experimental.todo = true;

        # Every agent's built-in defaults start with `* allow`, so unlisted
        # actions — including MCP write tools — would run silently. Override to
        # `ask` to match claude-code's deny-by-default, then allow safe built-ins
        # plus the shared allowlists. Rules are ordered; the last match wins.
        #
        # Merge order is: built-in agent rules -> these global rules -> per-agent
        # config rules. So the global `* ask` also clobbers built-in agent tunings
        # (Plan's `edit deny`, Explore's `* deny`, ...); `agents` below re-asserts
        # them. Never put `edit allow` here: it would make Plan writable.
        permissions =
          [
            (rule "*" "*" "ask")
            (rule "read" "*" "allow")
            (rule "read" "*.env" "ask")
            (rule "read" "*.env.*" "ask")
            (rule "read" "*.env.example" "allow")
            (rule "glob" "*" "allow")
            (rule "grep" "*" "allow")
            (rule "skill" "*" "allow")
            (rule "todowrite" "*" "allow")
            (rule "webfetch" "*" "allow")
            (rule "websearch" "*" "allow")
            # V2 allows paths outside the project by default; V1 asked.
            (rule "external_directory" "*" "ask")
          ]
          ++ map (p: rule "shell" p "allow") cfg.allowedBashCommands
          ++ expandMcpCalls cfg.allowedMcpCalls;

        agents = {
          build = {
            model = agentModel;
            permissions = [
              (rule "edit" "*" "allow")
              (rule "question" "*" "allow")
              (rule "subagent" "*" "allow")
            ];
          };
          plan = {
            model = agentModel;
            permissions = [
              (rule "question" "*" "allow")
              (rule "edit" "*" "deny")
              (rule "edit" "~/.opencode/plan/*" "allow")
            ];
          };
          general.permissions = [
            (rule "edit" "*" "allow")
            (rule "question" "*" "deny")
            (rule "subagent" "*" "deny")
          ];
          explore.permissions = [
            (rule "edit" "*" "deny")
            (rule "subagent" "*" "deny")
          ];
          code-reviewer = {
            description = "Reviews code for best practices and potential issues";
            mode = "subagent";
            model = agentModel;
            system = "You are a code reviewer. Focus on security, performance, and maintainability.";
            permissions = [(rule "edit" "*" "deny")];
          };
        };

        # No `lsp` block: V2 accepts it but runs no language servers.

        # Formatter Configuration
        formatter =
          {
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
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
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
  };
}
