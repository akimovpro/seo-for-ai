#!/usr/bin/env bash
# seo-for-ai installer — drops AGENTS.md and tool-specific rules into the current
# repository for whatever coding agents the user has files for.
#
# Usage:
#   ./install.sh                # auto-detect & install for everything detected
#   ./install.sh --all          # install all known formats unconditionally
#   ./install.sh --tool cursor  # install just one
#   ./install.sh --global       # install user-global where supported (Codex, Cursor)
#   ./install.sh --dry-run      # print what would happen
#
# Safe by default: never overwrites — appends or refuses with a message.

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/akimovpro/seo-for-ai/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE="auto"
SCOPE="local"
DRY=0
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --all) MODE="all" ;;
    --global) SCOPE="global" ;;
    --dry-run) DRY=1 ;;
    --tool) shift; ONLY="$1" ;;
    --tool=*) ONLY="${arg#*=}" ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
  esac
done

say()  { printf '\033[36m→\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
do_cp() {
  local src="$1" dst="$2"
  if [[ $DRY -eq 1 ]]; then
    echo "  would write: $dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    warn "exists, skipping: $dst (review and merge manually)"
    return
  fi
  if [[ -f "$src" ]]; then
    cp "$src" "$dst"
  else
    curl -fsSL "$REPO_RAW/$src" -o "$dst"
  fi
  ok "wrote $dst"
}

want() {
  local tool="$1"
  [[ "$MODE" == "all" ]] && return 0
  [[ -n "$ONLY" ]] && { [[ "$ONLY" == "$tool" ]]; return $?; }
  return 1
}

detect() {
  local tool="$1" marker="$2"
  [[ "$MODE" == "all" ]] && return 0
  [[ -n "$ONLY" ]] && { [[ "$ONLY" == "$tool" ]]; return $?; }
  [[ -e "$marker" ]] || command -v "$marker" >/dev/null 2>&1
}

say "scope: $SCOPE  mode: $MODE  dry: $DRY  only: ${ONLY:-<auto>}"
[[ "$SCOPE" == "global" ]] && say "operating on user-global locations"
[[ "$SCOPE" == "local"  ]] && say "operating on current repo: $(pwd)"

# ---------------- AGENTS.md (Codex CLI, OpenCode, Devin, Jules, Aider, generic) -
if want agents || detect agents "package.json" || detect agents .git; then
  if [[ "$SCOPE" == "global" ]]; then
    do_cp AGENTS.md "$HOME/.codex/AGENTS.md"
  else
    do_cp AGENTS.md "./AGENTS.md"
  fi
fi

# ---------------- Cursor (.cursor/rules/*.mdc) ------------------------------
if want cursor || detect cursor ".cursor"; then
  if [[ "$SCOPE" == "global" ]]; then
    do_cp dist/cursor/seo-for-ai.mdc "$HOME/.cursor/rules/seo-for-ai.mdc"
  else
    do_cp dist/cursor/seo-for-ai.mdc "./.cursor/rules/seo-for-ai.mdc"
  fi
fi

# ---------------- Windsurf (.windsurf/rules/*.md) ---------------------------
if want windsurf || detect windsurf ".windsurfrules" || detect windsurf ".windsurf"; then
  do_cp dist/windsurf/seo-for-ai.md "./.windsurf/rules/seo-for-ai.md"
fi

# ---------------- GitHub Copilot (.github/copilot-instructions.md) ----------
if want copilot || detect copilot ".github"; then
  do_cp dist/copilot/copilot-instructions.md "./.github/copilot-instructions.md"
fi

# ---------------- Claude Code (skill via plugin marketplace) ---------------
if want claude || detect claude "$HOME/.claude"; then
  if [[ $DRY -eq 1 ]]; then
    echo "  would suggest: /plugin marketplace add akimovpro/seo-for-ai"
  else
    cat <<'EOF'

  Claude Code uses the plugin marketplace. Run inside Claude Code:

      /plugin marketplace add akimovpro/seo-for-ai
      /plugin install seo-for-ai@seo-for-ai

EOF
  fi
fi

# ---------------- Aider (CONVENTIONS.md, opt-in via /read) ------------------
if want aider || detect aider ".aider.conf.yml" || detect aider .aider.tags.cache.v3; then
  do_cp AGENTS.md "./CONVENTIONS.md"
  if [[ $DRY -eq 0 ]]; then
    say "tell aider to use it:  aider --read CONVENTIONS.md  (or add to .aider.conf.yml)"
  fi
fi

# ---------------- Antigravity (Google) --------------------------------------
# Antigravity reads AGENTS.md at repo root and supports MCP — AGENTS.md above
# already covers it. Nothing extra to drop unless the user wants project-scoped
# overrides under .antigravity/rules/ (writeable but not required as of 2025-11).
if want antigravity; then
  do_cp AGENTS.md "./.antigravity/rules/seo-for-ai.md"
fi

ok "done. To run an audit at any time, paste the prompt from:"
echo "    $REPO_RAW/dist/audit-prompt.md"
