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
    textVerbosity = "low";
    effort = cfg.effortLevel;
    thinking = {
      type = "adaptive";
      display = "summarized";
    };
  };

  # opencode names each MCP tool `<sanitize(server)>_<sanitize(tool)>` and looks
  # up that exact string in the permission ruleset. `sanitize` in
  # packages/opencode/src/mcp/index.ts replaces every char outside [a-zA-Z0-9_-]
  # with `_`, so mirror that here.
  sanitize = s: let
    isAllowed = c: builtins.match "[a-zA-Z0-9_-]" c != null;
  in
    builtins.concatStringsSep "" (map (c:
      if isAllowed c
      then c
      else "_") (lib.stringToCharacters s));

  expandMcpCalls = calls:
    builtins.listToAttrs (lib.flatten (lib.mapAttrsToList (server: tools:
      map (tool: {
        name = "${sanitize server}_${sanitize tool}";
        value = "allow";
      })
      tools)
    calls));
in {
  home.sessionVariables = {
    OPENCODE_ENABLE_EXA = "1"; # enables https://opencode.ai/docs/de/tools/#websearch
  };

  programs.opencode = {
    enable = true;

    # opencode v2 via the official npm prebuilt (darwin-arm64, `beta` channel).
    # Darwin-only: our macs get v2; other platforms keep stable nixpkgs opencode.
    #
    # Why prebuilt rather than a source override: v2's real interactive CLI
    # diverges from what nixpkgs packages (packages/opencode), and a from-source
    # build does NOT reproduce a working `run`/TUI — the official CI build differs
    # in ways not worth chasing/maintaining for personal dotfiles (it would also
    # mean re-hashing a 12-min node_modules FOD on every bump). The official beta
    # binary works as-is; we just wrap it.
    #
    # Do NOT re-sign this binary. It's a Bun single-file executable: the JS/asset
    # payload is appended after the Mach-O. `codesign --force --sign -` doesn't
    # understand that trailer and truncates it (~900 KB), which drops the embedded
    # opentui/TUI resources — `run` still works but the TUI renders blank. The
    # binary's own Bun ad-hoc signature is accepted by Tahoe's kernel as-is (it
    # runs fine) even though `codesign --verify` reports the appended data as
    # "modified"; that verify complaint is harmless. Just wrap it (as nixpkgs
    # does) to put ripgrep on PATH and disable the self-updater.
    #
    # Bump: pick a version from `npm view opencode-ai dist-tags` (beta/dev), set
    # `version`, then update `hash` — `nix store prefetch-file <url>` prints it.
    package = lib.mkIf pkgs.stdenv.isDarwin (
      pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "opencode-v2-prebuilt";
        version = "0.0.0-beta-202607090949";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/opencode-darwin-arm64/-/opencode-darwin-arm64-${finalAttrs.version}.tgz";
          hash = "sha256-iKBueWPMNfgPSZsrXA3U+mQ+0+7jRWwKdrLln8tMg+U=";
        };
        sourceRoot = "package";

        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true; # keep the Bun binary byte-for-byte (no strip/re-sign)

        installPhase = ''
          runHook preInstall

          install -Dm755 bin/opencode $out/bin/.opencode-wrapped
          makeBinaryWrapper $out/bin/.opencode-wrapped $out/bin/opencode \
            --prefix PATH : ${lib.makeBinPath [pkgs.ripgrep pkgs.sysctl]} \
            --set OPENCODE_DISABLE_AUTOUPDATE true

          runHook postInstall
        '';

        meta = pkgs.opencode.meta // {mainProgram = "opencode";};
      })
    );
    enableMcpIntegration = true;
    tui = {
      theme = "catppuccin";
    };
    settings = {
      model = lib.mkDefault opencodeModel;
      instructions = ["${cfg.instructionsDir}/*.md"];
      autoupdate = false;
      disabled_providers = ["xai"];
      # opencode's build agent ships with `"*": "allow"` baked into its
      # defaults (packages/opencode/src/agent/agent.ts), so any unlisted
      # permission key runs silently — including MCP write tools. We override
      # `*` to `ask` here to match the deny-by-default model claude-code uses,
      # then explicitly allow opencode's safe built-ins (which previously
      # relied on the `*` catchall) plus the user's allowlist.
      #
      # `question` and `plan_enter` need re-allowing because the build agent
      # specifically toggles them allow in its merge step, and our user-level
      # `*: ask` lands later in the merged ruleset, shadowing those tunings.
      permission =
        {
          "*" = "ask";

          # safe built-ins — keep normal coding silent
          edit = "allow"; # covers edit / write / apply_patch (all use this key)
          glob = "allow";
          grep = "allow";
          list = "allow";
          lsp = "allow";
          skill = "allow";
          task = "allow";
          todowrite = "allow";
          webfetch = "allow";
          websearch = "allow";

          # re-establish build-agent overrides shadowed by our `*: ask`
          plan_enter = "allow";
          question = "allow";

          bash =
            {
              "*" = "ask";
            }
            // builtins.listToAttrs (map (p: {
                name = p;
                value = "allow";
              })
              cfg.allowedBashCommands);
        }
        // expandMcpCalls cfg.allowedMcpCalls;

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
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
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
