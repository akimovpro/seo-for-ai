#!/usr/bin/env bash
# seo-for-ai installer — fallback for agents WITHOUT a native plugin system.
#
# Native install paths (do NOT use this installer for these):
#   Claude Code     /plugin install seo-for-ai@seo-for-ai
#   Codex CLI       /plugins
#   Cursor          /add-plugin akimovpro/seo-for-ai
#   Gemini CLI      gemini extensions install https://github.com/akimovpro/seo-for-ai
#   Factory Droid   droid plugin install seo-for-ai@seo-for-ai
#   OpenCode        edit opencode.json (see .opencode/INSTALL.md)
#
# This installer covers everything else (Antigravity reads AGENTS.md; Windsurf,
# Copilot, Aider have no plugin marketplaces yet) and also lays down AGENTS.md
# as a universal baseline.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash
#   curl ... | bash -s -- --dry-run        # preview only
#   curl ... | bash -s -- --all            # write every supported format
#   curl ... | bash -s -- --tool windsurf  # just one
#   curl ... | bash -s -- --global         # also write user-global locations
#
# Safe by default: never overwrites an existing file.

set -eo pipefail
# NB: not using `set -u` — BASH_SOURCE is unset under a curl|bash pipe.

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
      curl -fsSL "$REPO_RAW/install.sh" 2>/dev/null | sed -n '1,28p' \
        || sed -n '1,28p' "$0" 2>/dev/null
      exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift || true
done

say()  { printf '\033[36m→\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }

# Detection — each returns 'y' or 'n'. Explicit if/else (avoids && || trap).
detect_codex() {
  if command -v codex >/dev/null 2>&1 || [[ -d "$HOME/.codex" ]]; then
    echo y; else echo n; fi
}
detect_antigravity() {
  if [[ -d "/Applications/Antigravity.app" ]] || [[ -d "$HOME/.antigravity" ]] || [[ -d "$HOME/Library/Application Support/Antigravity" ]]; then
    echo y; else echo n; fi
}
detect_windsurf() {
  if [[ -e ".windsurfrules" ]] || [[ -d ".windsurf" ]] || [[ -d "$HOME/.windsurf" ]] || [[ -d "/Applications/Windsurf.app" ]] || command -v windsurf >/dev/null 2>&1; then
    echo y; else echo n; fi
}
detect_copilot_repo() {
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

HAS_CODEX=$(detect_codex)
HAS_ANTIGRAVITY=$(detect_antigravity)
HAS_WINDSURF=$(detect_windsurf)
HAS_COPILOT=$(detect_copilot_repo)
HAS_AIDER=$(detect_aider)

# --all > --tool > auto-detect
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
detected on this machine (this installer only handles agents WITHOUT a plugin marketplace):
  Codex CLI    : $HAS_CODEX      (reads AGENTS.md — covered. Native: '/plugins')
  Antigravity  : $HAS_ANTIGRAVITY      (reads AGENTS.md — covered)
  Windsurf     : $HAS_WINDSURF      (drops .windsurf/rules/seo-for-ai.md)
  Aider        : $HAS_AIDER      (drops CONVENTIONS.md)
  GitHub repo  : $HAS_COPILOT      (drops .github/copilot-instructions.md)

agents WITH a native plugin marketplace — install via their own command, not this script:
  Claude Code     /plugin install seo-for-ai@seo-for-ai
  Codex CLI       /plugins
  Cursor          /add-plugin akimovpro/seo-for-ai
  Gemini CLI      gemini extensions install https://github.com/akimovpro/seo-for-ai
  Factory Droid   droid plugin install seo-for-ai@seo-for-ai
  OpenCode        edit opencode.json (see .opencode/INSTALL.md)

EOF

# 1. AGENTS.md — always. Universal baseline read by Codex CLI, Antigravity,
#    OpenCode, Devin, Jules, Continue.
do_cp AGENTS.md "./AGENTS.md"

# 2. User-global (--global) — for Codex CLI before they wire up the plugin
#    marketplace properly.
if [[ "$SCOPE" == "global" ]]; then
  say "writing user-global rules"
  do_cp AGENTS.md "$HOME/.codex/AGENTS.md"
fi

# 3. Per-tool local rule files (fallback only).
should windsurf "$HAS_WINDSURF" && do_cp dist/windsurf/seo-for-ai.md          "./.windsurf/rules/seo-for-ai.md"
should copilot  "$HAS_COPILOT"  && do_cp dist/copilot/copilot-instructions.md "./.github/copilot-instructions.md"
should aider    "$HAS_AIDER"    && do_cp AGENTS.md                            "./CONVENTIONS.md"

# 4. Wrap up.
ok "done."
if [[ $DRY -eq 1 ]]; then
  echo
  say "this was --dry-run. Re-run without --dry-run to actually write files."
else
  echo
  say "for a one-shot audit at any time, paste the prompt at:"
  echo "    $REPO_RAW/dist/audit-prompt.md"
fi
