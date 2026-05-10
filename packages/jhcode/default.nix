# TESTING — smoke-test these on every change:
#   jhcode claude -p "say hi"        # flag with value passthrough
#   jhcode claude /mcp               # slash-command as positional
#   jhcode claude --resume foo       # multi-token flag passthrough
#   jhcode claude                    # Test websearch (tool disabled, exa used)
#   jhcode opencode -p "say hi"      # opencode model selection + flag
{pkgs}:
pkgs.writeShellApplication {
  name = "jhcode";
  runtimeInputs = with pkgs; [_1password-cli curl jq fzf];
  text = ''
    set -euo pipefail

    BASE_URL="''${JHC_AI_BASE_URL:-https://ai.jhofer.org}"
    OP_REF="''${JHC_AI_OP_REF:-op://Personal/jhc-ai/api_live}"

    usage() {
      cat >&2 <<EOF
    usage: jhcode <claude|opencode> [-m MODEL] [args...]

    Wraps claude-code or opencode to use the JHC AI gateway at $BASE_URL.
    API key fetched from 1Password ($OP_REF).

    Model selection (both subcommands):
      1. -m / --model flag (consumed by wrapper, not passed through)
      2. \$JHC_AI_MODEL env var
      3. fzf picker over /v1/models (interactive)

    Subcommands:
      claude [-m MODEL] [args...]
        Sets ANTHROPIC_BASE_URL/AUTH_TOKEN/MODEL/DEFAULT_HAIKU_MODEL +
        ANTHROPIC_CUSTOM_MODEL_OPTION (bypasses CC's "claude-/anthropic-"
        picker filter), then exec claude with remaining args.

      opencode [-m MODEL] [args...]
        Injects a "jhc" provider (with auto-discovered models) via
        OPENCODE_CONFIG_CONTENT — merges with home-manager-managed global
        config, no file written. Then exec opencode --model jhc/<picked>
        with remaining args.

    Env overrides: JHC_AI_BASE_URL, JHC_AI_OP_REF, JHC_AI_MODEL, JHC_AI_HAIKU_MODEL
    EOF
      exit 2
    }

    [ $# -lt 1 ] && usage

    mode=$1; shift
    api_key=$(op read "$OP_REF")

    fetch_models() {
      curl -fsSL -H "Authorization: Bearer $api_key" "$BASE_URL/v1/models"
    }

    # Sets globals MODEL and REMAINING from "$@".
    # MODEL: from -m/--model > $JHC_AI_MODEL > fzf picker.
    # REMAINING: positional args minus the consumed model flag.
    select_model() {
      local override=""
      REMAINING=()
      while [ $# -gt 0 ]; do
        case "$1" in
          -m|--model)
            override="''${2:?missing value for $1}"
            shift 2
            ;;
          -m=*|--model=*)
            override="''${1#*=}"
            shift
            ;;
          *)
            REMAINING+=("$1")
            shift
            ;;
        esac
      done

      if [ -n "$override" ]; then
        MODEL="$override"
      elif [ -n "''${JHC_AI_MODEL:-}" ]; then
        MODEL="$JHC_AI_MODEL"
      else
        local json
        if ! json=$(fetch_models); then
          echo "jhcode: failed to fetch models from $BASE_URL/v1/models" >&2
          exit 1
        fi
        if ! MODEL=$(jq -r '.data[].id | select(test("embed"; "i") | not)' <<< "$json" \
            | fzf --prompt="model> " --height=40% --reverse); then
          echo "jhcode: no model selected" >&2
          exit 1
        fi
      fi
    }

    case "$mode" in
      claude)
        MODEL=""; REMAINING=()
        select_model "$@"
        HAIKU_MODEL="''${JHC_AI_HAIKU_MODEL:-$MODEL}"

        export ANTHROPIC_BASE_URL="$BASE_URL"
        export ANTHROPIC_AUTH_TOKEN="$api_key"
        export ANTHROPIC_MODEL="$MODEL"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="$HAIKU_MODEL"
        export ANTHROPIC_CUSTOM_MODEL_OPTION="$MODEL"
        export ANTHROPIC_CUSTOM_MODEL_OPTION_NAME="JHC AI ($MODEL)"

        # Built-in WebSearch is broken on a self-hosted gateway (it's an
        # Anthropic-hosted server-side tool). Suppress it AND inject Exa as
        # a replacement via per-invocation MCP — merges with global MCPs.
        # `=` syntax for --disallowedTools so it doesn't greedily consume
        # subsequent positional args (slash commands, prompts).
        mcp_inline='{"mcpServers":{"exa":{"command":"npx","args":["-y","mcp-remote","https://mcp.exa.ai/mcp"]}}}'
        if [ ''${#REMAINING[@]} -gt 0 ]; then
          exec claude --mcp-config "$mcp_inline" --disallowedTools=WebSearch "''${REMAINING[@]}"
        else
          exec claude --mcp-config "$mcp_inline" --disallowedTools=WebSearch
        fi
        ;;
      opencode)
        MODEL=""; REMAINING=()
        select_model "$@"

        export JHC_AI_KEY="$api_key"
        if ! models_json=$(fetch_models); then
          echo "jhcode: failed to fetch models from $BASE_URL/v1/models" >&2
          exit 1
        fi
        OPENCODE_CONFIG_CONTENT=$(jq -c \
          --arg base "$BASE_URL/v1" \
          --arg model "jhc/$MODEL" '
          {
            "$schema": "https://opencode.ai/config.json",
            model: $model,
            agent: {
              build: {model: $model},
              plan: {model: $model}
            },
            provider: {
              jhc: {
                npm: "@ai-sdk/openai-compatible",
                name: "JHC AI",
                options: {baseURL: $base, apiKey: "{env:JHC_AI_KEY}"},
                models: (
                  .data
                  | map(select(.id | test("embed"; "i") | not))
                  | map({(.id): {name: .id}})
                  | add
                )
              }
            }
          }' <<< "$models_json")
        export OPENCODE_CONFIG_CONTENT

        exec opencode --model "jhc/$MODEL" "''${REMAINING[@]}"
        ;;
      *)
        usage
        ;;
    esac
  '';
}
