# Claude Code Status Line

[![Claude Code](https://img.shields.io/badge/Claude%20Code-hooks-blueviolet)](https://code.claude.com/docs/en/hooks)

A color-coded status line for Claude Code CLI — context window usage, rate limits, project info, and git branch. Single file, under 100 lines, no dependencies.

![demo](demo.png)

Everything is color-coded: context bar shifts green → yellow (60K+ tokens) → orange (80K+ tokens), rate limits turn red at >80%.

**Segments:** model, project, git branch, time, context bar with tokens, 5h session usage, 7d weekly usage.

## Install

```bash
git clone https://github.com/anthropics/claude-code-status-line.git
cd claude-code-status-line
bash install.sh
```

Copies `status-line.js` to `~/.claude/` and patches `~/.claude/settings.json` (with backup).

### Manual install

```bash
cp status-line.js ~/.claude/
```

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "node ~/.claude/status-line.js",
    "padding": 0
  }
}
```

## Configuration

Edit thresholds in `~/.claude/status-line.js`:

```javascript
const AUTOCOMPACT_BUFFER_TOKENS = 33_000;  // subtracted from raw window
const WARN_TOKENS = 60_000;                // yellow
const COMPACT_TOKENS = 80_000;             // orange
```

## Uninstall

```bash
rm ~/.claude/status-line.js
```

Then remove the `statusLine` entry from `~/.claude/settings.json`.
