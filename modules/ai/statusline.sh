#!/usr/bin/env bash

# Catppuccin Macchiato palette (true color)
RED="\033[38;2;237;135;150m"
PEACH="\033[38;2;245;169;127m"
YELLOW="\033[38;2;238;212;159m"
GREEN="\033[38;2;166;218;149m"
TEAL="\033[38;2;139;213;202m"
BLUE="\033[38;2;138;173;244m"
LAVENDER="\033[38;2;183;189;248m"
SUBTEXT0="\033[38;2;165;173;206m"
OVERLAY1="\033[38;2;128;135;162m"
PINK="\033[38;2;245;189;230m"
RESET="\033[0m"

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

# Optional fields (only present in some harness builds; safely empty otherwise)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
effort=$(echo "$input" | jq -r '.effort_level // .effortLevel // empty')
if [ -z "$effort" ] && [ -f "$HOME/.claude/settings.json" ]; then
  effort=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)
fi

# Fallback: derive context % from transcript JSONL when harness doesn't expose it
if [ -z "$used_pct" ] && [ -n "$transcript" ] && [ -f "$transcript" ]; then
  toks=$(grep '"usage"' "$transcript" 2>/dev/null | tail -1 | jq -r '(.message.usage.input_tokens // 0) + (.message.usage.cache_read_input_tokens // 0) + (.message.usage.cache_creation_input_tokens // 0)' 2>/dev/null)
  if [ -n "$toks" ] && [ "$toks" -gt 0 ]; then
    case "$model" in *1M*) lim=1000000 ;; *) lim=200000 ;; esac
    used_pct=$((toks * 100 / lim))
  fi
fi

sep="${OVERLAY1}•${RESET}"

# Model
out="${BLUE}󰧑 ${model}${RESET}"

# Output style (only when non-default)
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
  out="${out} ${sep} ${LAVENDER}${output_style}${RESET}"
fi

# Effort level
if [ -n "$effort" ]; then
  out="${out} ${sep} ${TEAL}󰓅 ${effort}${RESET}"
fi

# Context % (color-coded)
if [ -n "$used_pct" ]; then
  pct=$(printf "%.0f" "$used_pct")
  if [ "$pct" -lt 50 ]; then
    ctx_color=$GREEN
  elif [ "$pct" -lt 75 ]; then
    ctx_color=$YELLOW
  elif [ "$pct" -lt 90 ]; then
    ctx_color=$PEACH
  else
    ctx_color=$RED
  fi
  out="${out} ${sep} ${ctx_color}󰋊 ${pct}%${RESET}"
fi

# Rate limits (5h / 7d), if available
if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
  out="${out} ${sep} ${PINK}󱫋${RESET}"
  for pair in "5h:$five_hour_pct" "7d:$seven_day_pct"; do
    label="${pair%%:*}"
    val="${pair#*:}"
    [ -z "$val" ] && continue
    r=$(printf "%.0f" "$val")
    if [ "$r" -lt 75 ]; then
      lc=$GREEN
    elif [ "$r" -lt 90 ]; then
      lc=$YELLOW
    else
      lc=$RED
    fi
    out="${out} ${lc}${label}:${r}%${RESET}"
  done
fi

# Session cost
out="${out} ${sep} ${GREEN}\$$(printf "%.2f" "$cost")${RESET}"

# Git branch + dirty file count
if [ -d "$cwd" ]; then
  git_branch=$(cd "$cwd" 2>/dev/null && git branch --show-current 2>/dev/null)
  if [ -n "$git_branch" ]; then
    git_dirty=$(cd "$cwd" 2>/dev/null && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$git_dirty" -gt 0 ]; then
      out="${out} ${sep} ${PEACH} ${git_branch} (${git_dirty})${RESET}"
    else
      out="${out} ${sep} ${PEACH} ${git_branch}${RESET}"
    fi
  fi
fi

# Directory
dir_short=$(basename "$cwd")
out="${out} ${sep} ${SUBTEXT0} ${dir_short}${RESET}"

printf "%b" "$out"
