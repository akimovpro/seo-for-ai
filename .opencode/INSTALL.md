# Installing seo-for-ai for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed.

## Installation

Add `seo-for-ai` to the `plugin` array in your `opencode.json` (global at
`~/.config/opencode/opencode.json`, or project-level):

```json
{
  "plugin": ["seo-for-ai@git+https://github.com/akimovpro/seo-for-ai.git"]
}
```

Restart OpenCode. The plugin registers all skills under `skills/`.

Verify by asking:

```
use skill tool to list skills
```

You should see `seo-for-ai` in the list.

## Pinning a specific version

```json
{
  "plugin": ["seo-for-ai@git+https://github.com/akimovpro/seo-for-ai.git#v1.3.0"]
}
```

## Updating

OpenCode pins git-backed plugins in a lockfile. If updates don't appear after
restart, clear the package cache or reinstall:

```sh
rm -rf ~/.config/opencode/node_modules/seo-for-ai
```

Then restart OpenCode.

## Usage

```
use skill tool to load seo-for-ai
```

Or just describe the task in natural language ("audit this site for AI
visibility", "review my JSON-LD") — the skill auto-activates.

## Troubleshooting

- **Plugin not loading:**
  `opencode run --print-logs "hello" 2>&1 | grep -i seo-for-ai`
- **Skills not found:**
  Use `skill` tool to list discovered skills. Confirm plugin is in the
  `plugin` array of `opencode.json`.
- **Windows install issues** (Bun + `git+https` cache paths): install via
  `npm` and point OpenCode at the local path —
  ```powershell
  npm install seo-for-ai@git+https://github.com/akimovpro/seo-for-ai.git --prefix "$HOME\.config\opencode"
  ```
  Then:
  ```json
  { "plugin": ["~/.config/opencode/node_modules/seo-for-ai"] }
  ```

## Help

Issues: <https://github.com/akimovpro/seo-for-ai/issues>
