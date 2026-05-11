#!/usr/bin/env bash
# seo-for-ai installer — drops AGENTS.md and tool-specific rules wherever the
# user's coding agents will read them.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash
#   curl ... | bash -s -- --dry-run        # see what would happen
#   curl ... | bash -s -- --all            # write every supported format
#   curl ... | bash -s -- --tool cursor    # just one tool
#   curl ... | bash -s -- --global         # also write user-global locations
#
# Behavior:
#   - AGENTS.md is ALWAYS written in the current directory. This is the
#     universal baseline — read by Codex CLI, Antigravity, OpenCode, Devin,
#     Jules, Continue, and by Cursor when you @-mention it. Harmless if a
#     given tool doesn't read it.
#   - Per-tool rule files (Cursor MDC, Windsurf, Copilot, Aider CONVENTIONS)
#     are written only when the tool is detected on this machine — unless you
#     pass --all or --tool.
#   - With --global, also installs to user-wide locations (e.g.
#     ~/.codex/AGENTS.md, ~/.cursor/rules/).
#   - Safe by default: never overwrites an existing file.

set -eo pipefail
# NB: not using `set -u` — when piped via curl|bash, BASH_SOURCE is unset.

REPO_RAW="https://raw.githubusercontent.com/akimovpro/seo-for-ai/main"

MODE="auto"        # auto | all
SCOPE="local"      # local (default) — pass --global to also do user-wide
DRY=0
ONLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)     MODE="all" ;;
    --global)  SCOPE="global" ;;
    --dry-run) DRY=1 ;;
    --tool)    shift; ONLY="${1:-}" ;;
    --tool=*)  ONLY="${1#*=}" ;;
    -h|--help)
      curl -fsSL "$REPO_RAW/install.sh" 2>/dev/null | sed -n '1,24p' \
        || { sed -n '1,24p' "$0" 2>/dev/null; }
      exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift || true
done

say()  { printf '\033[36m→\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }

# Tool detection — each returns 'y' or 'n' on stdout.
# (Explicit if/else avoids the && || precedence trap.)
detect_codex() {
  if command -v codex >/dev/null 2>&1 || [[ -d "$HOME/.codex" ]]; then
    echo y; else echo n; fi
}
detect_cursor() {
  if [[ -d ".cursor" ]] || [[ -d "$HOME/.cursor" ]] || [[ -d "/Applications/Cursor.app" ]] || command -v cursor >/dev/null 2>&1; then
    echo y; else echo n; fi
}
detect_windsurf() {
  if [[ -e ".windsurfrules" ]] || [[ -d ".windsurf" ]] || [[ -d "$HOME/.windsurf" ]] || [[ -d "/Applications/Windsurf.app" ]] || command -v windsurf >/dev/null 2>&1; then
    echo y; else echo n; fi
}
detect_copilot_repo() {
  # Detect "this looks like a repo where Copilot would be in use" — strict
  # signal so we don't drop .github/ into random folders. .git with a github
  # remote, OR an existing .github/ directory.
  if [[ -d ".github" ]]; then echo y; return; fi
  if [[ -f ".git/config" ]] && grep -qE 'github\.com' .git/config 2>/dev/null; then
    echo y; return
  fi
  echo n
}
detect_aider() {
  if command -v aider >/dev/null 2>&1 || [[ -e ".aider.conf.yml" ]]; then
    echo y; else echo n; fi
}
detect_antigravity() {
  if [[ -d "/Applications/Antigravity.app" ]] || [[ -d "$HOME/.antigravity" ]] || [[ -d "$HOME/Library/Application Support/Antigravity" ]]; then
    echo y; else echo n; fi
}
detect_claude() {
  if command -v claude >/dev/null 2>&1 || [[ -d "$HOME/.claude" ]]; then
    echo y; else echo n; fi
}

HAS_CODEX=$(detect_codex)
HAS_CURSOR=$(detect_cursor)
HAS_WINDSURF=$(detect_windsurf)
HAS_COPILOT=$(detect_copilot_repo)
HAS_AIDER=$(detect_aider)
HAS_ANTIGRAVITY=$(detect_antigravity)
HAS_CLAUDE=$(detect_claude)

# Decide whether to act for a given tool: --all > --tool > auto-detect.
should() {
  local tool="$1" detected="$2"
  [[ "$MODE" == "all" ]] && return 0
  if [[ -n "$ONLY" ]]; then
    [[ "$ONLY" == "$tool" ]]; return $?
  fi
  [[ "$detected" == "y" ]] && return 0
  return 1
}

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
  if ! curl -fsSL "$REPO_RAW/$src" -o "$dst"; then
    warn "fetch failed for $src — left $dst untouched"
    rm -f "$dst" 2>/dev/null || true
    return
  fi
  ok "wrote $dst"
}

# --------------------------------------------------------------------------
say "scope: $SCOPE  mode: $MODE  dry: $DRY  only: ${ONLY:-<auto>}"
say "cwd: $(pwd)"
cat <<EOF
detected on this machine:
  Codex CLI    : $HAS_CODEX      (reads AGENTS.md — covered)
  Antigravity  : $HAS_ANTIGRAVITY      (reads AGENTS.md — covered)
  Cursor       : $HAS_CURSOR      (drops .cursor/rules/seo-for-ai.mdc)
  Windsurf     : $HAS_WINDSURF      (drops .windsurf/rules/seo-for-ai.md)
  Aider        : $HAS_AIDER      (drops CONVENTIONS.md)
  GitHub repo  : $HAS_COPILOT      (drops .github/copilot-instructions.md for Copilot)
  Claude Code  : $HAS_CLAUDE      (uses /plugin marketplace, not a file)

EOF

# 1. AGENTS.md — always. Covers Codex CLI, Antigravity, OpenCode, Devin,
#    Jules, Continue, and Cursor's @-file workflow. Harmless to other tools.
do_cp AGENTS.md "./AGENTS.md"

# 2. User-global (--global) — write rules where any project picks them up.
if [[ "$SCOPE" == "global" ]]; then
  say "writing user-global rules"
  do_cp AGENTS.md "$HOME/.codex/AGENTS.md"
  do_cp dist/cursor/seo-for-ai.mdc "$HOME/.cursor/rules/seo-for-ai.mdc"
fi

# 3. Per-tool local rule files.
should cursor   "$HAS_CURSOR"   && do_cp dist/cursor/seo-for-ai.mdc           "./.cursor/rules/seo-for-ai.mdc"
should windsurf "$HAS_WINDSURF" && do_cp dist/windsurf/seo-for-ai.md          "./.windsurf/rules/seo-for-ai.md"
should copilot  "$HAS_COPILOT"  && do_cp dist/copilot/copilot-instructions.md "./.github/copilot-instructions.md"
should aider    "$HAS_AIDER"    && do_cp AGENTS.md                            "./CONVENTIONS.md"

# 4. Claude Code — plugin marketplace, not a file.
if should claude "$HAS_CLAUDE"; then
  if [[ $DRY -eq 1 ]]; then
    echo "  would suggest: /plugin marketplace add akimovpro/seo-for-ai"
  else
    cat <<'EOF'

  Claude Code installs via the plugin marketplace, not a file copy.
  Run inside Claude Code:

      /plugin marketplace add akimovpro/seo-for-ai
      /plugin install seo-for-ai@seo-for-ai

EOF
  fi
fi

# 5. Wrap up.
ok "done."
if [[ $DRY -eq 1 ]]; then
  echo
  say "this was --dry-run. Re-run without --dry-run to actually write files."
else
  echo
  say "for a one-shot audit at any time, paste the prompt at:"
  echo "    $REPO_RAW/dist/audit-prompt.md"
fi
