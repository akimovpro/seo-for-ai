# Installing seo-for-ai

Three ways to install, from easiest to most explicit. Pick whichever matches
how you work.

## Option 1 — agent-assisted (universal, easiest)

Open your AI coding agent (Claude Code, Codex CLI, Cursor, Gemini CLI,
OpenCode, Aider, Continue, Antigravity, Factory Droid — anything) and paste:

```
Install the seo-for-ai skill for me: https://github.com/akimovpro/seo-for-ai
```

The agent will figure out where its skills live, fetch the repo, and put the
files in the right place. Works in every host that has filesystem access.

## Option 2 — native plugin marketplace (best UX, auto-updates)

If your agent has a plugin marketplace, use it. You get a proper version
record and `update` command.

### Claude Code

```
/plugin marketplace add akimovpro/seo-for-ai
/plugin install seo-for-ai@seo-for-ai
```

Includes the `/seo-audit` slash command. Update with `/plugin update seo-for-ai`.

### Codex CLI

```
/plugins
```

Then search for **seo-for-ai** and install. Or add the marketplace by URL:

```
/plugins marketplace add https://github.com/akimovpro/seo-for-ai
```

### Cursor

```
/add-plugin akimovpro/seo-for-ai
```

### Gemini CLI

```
gemini extensions install https://github.com/akimovpro/seo-for-ai
gemini extensions update seo-for-ai
```

### Factory Droid

```
droid plugin marketplace add https://github.com/akimovpro/seo-for-ai
droid plugin install seo-for-ai@seo-for-ai
droid plugin update seo-for-ai
```

### OpenCode

Add to your `opencode.json` (global at `~/.config/opencode/opencode.json` or
project-level):

```json
{
  "plugin": ["seo-for-ai@git+https://github.com/akimovpro/seo-for-ai.git"]
}
```

Full instructions including pinning and troubleshooting: [.opencode/INSTALL.md](./.opencode/INSTALL.md).

## Option 3 — direct git clone (host-agnostic, works everywhere)

For agents that read a skills directory but don't have a plugin marketplace.
Just clone the repo into the agent's skills directory.

| Host | Command |
|---|---|
| Claude Code | `git clone https://github.com/akimovpro/seo-for-ai ~/.claude/skills/seo-for-ai` |
| Codex CLI | `git clone https://github.com/akimovpro/seo-for-ai ~/.codex/skills/seo-for-ai` |
| OpenClaw | `git clone https://github.com/akimovpro/seo-for-ai ~/.openclaw/workspace/skills/seo-for-ai` |
| Hermes | `git clone https://github.com/akimovpro/seo-for-ai && cd seo-for-ai && python3 tools/install_hermes_skill.py --force` (if available) |

The skill content under `skills/seo-for-ai/SKILL.md` will activate on its
natural-language triggers.

To update: `cd ~/.claude/skills/seo-for-ai && git pull`.

## Option 4 — fallback shell installer (Windsurf, Aider, Copilot, Antigravity)

For agents that don't have a plugin marketplace **and** don't read a skills
directory. The installer drops the right rule file in the right place. Safe
by default — never overwrites.

```sh
# auto-detect what's installed on this machine, write the right rules:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash

# preview first:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --dry-run

# force every supported format:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --all

# user-global (~/.codex/AGENTS.md):
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --global

# just one tool:
curl -fsSL https://raw.githubusercontent.com/akimovpro/seo-for-ai/main/install.sh | bash -s -- --tool windsurf
```

What lands where:

- **Antigravity** → `AGENTS.md` in the current repo (Antigravity reads it).
- **Windsurf** → `.windsurf/rules/seo-for-ai.md`.
- **GitHub Copilot** → `.github/copilot-instructions.md`.
- **Aider** → `CONVENTIONS.md` (use `aider --read CONVENTIONS.md`).

## Option 5 — copy-paste prompt (ChatGPT web, plain Claude, no filesystem)

If you're in a web chat that can't touch files, paste the prompt from
[`dist/audit-prompt.md`](./dist/audit-prompt.md) into the conversation,
optionally substituting `<URL>` with the page you want audited. Works as a
one-shot audit anywhere.

## Verifying the install worked

In any host, try:

> "Run a quick AI-visibility audit on https://example.com — just a sanity check."

You should see the skill kick in and produce a punch list with sections
**Blocker / High / Medium / Watch / What's already correct**. If you get a
generic SEO answer with no skill markers, the install didn't take effect.

## Updating

| How you installed | Update command |
|---|---|
| Native plugin (Claude, Codex, Cursor, Gemini, Droid) | each agent has an `update` command — see Option 2 |
| OpenCode | restart; clear cache if needed (see [.opencode/INSTALL.md](./.opencode/INSTALL.md)) |
| Direct git clone | `cd <skill-dir> && git pull` |
| Shell installer | re-run; existing files are preserved |

## Uninstall

| Install method | How to remove |
|---|---|
| Claude Code plugin | `/plugin uninstall seo-for-ai` |
| Codex / Cursor / Droid plugin | their `uninstall` command |
| Gemini extension | `gemini extensions uninstall seo-for-ai` |
| OpenCode | remove from `opencode.json` plugin array, restart |
| Direct git clone | `rm -rf <skill-dir>` |
| Shell installer | manually delete the files it wrote (paths printed at install time) |
