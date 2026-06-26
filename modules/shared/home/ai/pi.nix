{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai;
  piCfg = config.programs.pi-coding-agent;

  # allowedBashCommands → bash section
  # "*" has ASCII value 42, so builtins.toJSON sorts it before any letter,
  # meaning the catch-all appears first — correct for last-match-wins semantics.
  bashRules =
    {"*" = "ask";}
    // lib.listToAttrs (
      map (cmd: lib.nameValuePair cmd "allow") cfg.allowedBashCommands
    );

  # Sanitise a server name the way pi-mcp-adapter does when deriving
  # underscore-format targets: only "-" → "_", dots and slashes are kept.
  sanitizeMcpName = builtins.replaceStrings ["-"] ["_"];

  # allowedMcpCalls → mcp section
  # Format: "serverName:toolName" — matches the Server/tool combo pattern in the docs.
  # Strip leading "@" from server names: in allowedMcpCalls it signals a
  # direct-config server (a claude-code convention); pi-mcp-adapter uses plain
  # names, so "@exa" → "exa" to match the actual registered server name.
  # No "*" = "ask" catch-all here — it would intercept search query strings and
  # other non-rule values that appear first in the permission target array, blocking
  # mcp_search/mcp_connect/etc. before they can be reached. Unlisted tool calls fall
  # through to tools.mcp (set to "ask" below) instead.
  mcpRules =
    lib.foldlAttrs (
      acc: server: tools: let
        serverName = lib.removePrefix "@" server;
        sanitized = sanitizeMcpName serverName;
      in
        acc
        // lib.listToAttrs (
          lib.flatten (
            map (tool: [
              # colon format  — "server:tool"
              (lib.nameValuePair "${serverName}:${tool}" "allow")
              # underscore format — "server_tool" (what pi-mcp-adapter actually emits)
              (lib.nameValuePair "${sanitized}_${tool}" "allow")
            ])
            tools
          )
        )
    ) {}
    cfg.allowedMcpCalls;

  # pi-mcp-adapter baseline discovery/connection ops — always allow regardless
  # of what allowedMcpCalls contains.
  mcpBaselineRules = {
    mcp_connect = "allow";
    "mcp_connect_*" = "allow";
    mcp_describe = "allow";
    mcp_list = "allow";
    mcp_search = "allow";
    "mcp_server_*" = "allow"; # server-list targets: mcp({ server: "name" }) → mcp_server_<name>
    mcp_status = "allow";
  };

  # Build a pi-mcp-adapter server object, omitting optional fields when unset.
  mkServerConfig = server:
    lib.optionalAttrs (server.command != null) {inherit (server) command;}
    // lib.optionalAttrs (server.args != []) {inherit (server) args;}
    // lib.optionalAttrs (server.url != null) {inherit (server) url;}
    // lib.optionalAttrs (server.env != {}) {inherit (server) env;}
    // lib.optionalAttrs (server.lifecycle != null) {inherit (server) lifecycle;}
    // lib.optionalAttrs (server.directTools != false) {inherit (server) directTools;};
in {
  # TODO: upstream pi enableMcpIntegration if it works
  # Extend programs.pi-coding-agent with an mcpServers option so that other
  # modules (e.g. workkit) can register MCP servers for pi the same way they
  # do for claude-code, copilot, etc. — without needing home-manager upstream
  # support for enableMcpIntegration.
  options.programs.pi-coding-agent.mcpServers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        command = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        url = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        env = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
        };
        lifecycle = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum ["lazy" "eager" "keep-alive"]);
          default = null;
        };
        directTools = lib.mkOption {
          type = lib.types.either lib.types.bool (lib.types.listOf lib.types.str);
          default = false;
        };
      };
    });
    default = {};
    description = ''
      MCP servers for pi-mcp-adapter. Serialised to ~/.pi/agent/mcp.json,
      which pi-mcp-adapter layers on top of ~/.config/mcp/mcp.json.
    '';
  };

  config = {
    programs.pi-coding-agent = {
      enable = true;

      mcpServers.exa = {
        command = "${pkgs._1password-cli}/bin/op";
        args = ["run" "--" "npx" "-y" "exa-mcp-server"];
        env.EXA_API_KEY = "op://Personal/Exa/api_key";
        lifecycle = "keep-alive";
      };

      settings = {
        compaction = {
          enabled = true;
          # keepRecentTokens = 20000;
          # reserveTokens = 16384;
        };
        quietStartup = true;
        enableInstallTelemetry = false;
        enableAnalytics = false;
        # editorPaddingX = 10;
        warnings.anthropicExtraUsage = false;
        defaultProvider = "github-copilot";
        defaultModel = cfg.model;
        defaultThinkingLevel = cfg.effortLevel;
        # enabledModels = [
        #   "claude-*"
        #   "gpt-4o"
        # ];
        packages = [
          "npm:@ayulab/pi-rewind"
          "npm:@firstpick/pi-themes-bundle"
          "npm:pi-claude-auth"
          "npm:pi-mcp-adapter"
          "npm:pi-permission-system"
          "npm:pi-subagents"
          # "npm:pi-web-access" # broken; using exa MCP server directly instead
          "pi-skills"
          # "npm:@termdraw/pi"
        ];
        retry = {
          enabled = true;
          maxRetries = 3;
        };
        theme = "catppuccin-macchiato";
      };
    };

    # Serialise mcpServers into the Pi-specific MCP override file.
    # ~/.config/mcp/mcp.json (from programs.mcp) is read first by pi-mcp-adapter;
    # this file layers on top of it, so workkit and other modules only need to
    # set programs.pi-coding-agent.mcpServers.<name> = { ... }.
    home.file.".pi/agent/mcp.json".text = builtins.toJSON {
      mcpServers = lib.mapAttrs (_: mkServerConfig) piCfg.mcpServers;
    };

    # pi-permission-system policy file.
    # NOTE: allowedDomains has no pi-permission-system equivalent — domain-level
    # filtering is not supported. Exa MCP tools are gated via the mcp section.
    home.file.".pi/agent/pi-permissions.jsonc".text = builtins.toJSON {
      defaultPolicy = {
        tools = "ask";
        bash = "ask";
        mcp = "ask";
        skills = "ask";
        special = "ask";
      };

      # Pi has no built-in plan/edit mode, so `ask` on write/edit acts as the
      # safety gate (equivalent to plan mode in opencode/claude-code).
      tools = {
        "*" = "ask";
        bash = "ask"; # fine-grained control via bash section below
        edit = "ask"; # no plan mode → confirm before edits
        find = "allow";
        grep = "allow";
        ls = "allow";
        mcp = "ask"; # fallback for unlisted mcp targets; specific mcp rules override this
        read = "allow";
        task = "ask";
        write = "ask"; # no plan mode → confirm before writes
      };

      # allowedBashCommands → allow; everything else asks.
      bash = bashRules;

      # allowedMcpCalls → allow listed server:tool pairs; everything else asks.
      # Baseline discovery/connection ops are always allowed on top.
      mcp = mcpBaselineRules // mcpRules;

      special = {
        doom_loop = "deny";
        external_directory = "ask";
      };
    };
  };
}
