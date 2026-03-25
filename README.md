# Claude Code Status Line

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-hooks-blueviolet)](https://code.claude.com/docs/en/hooks)

A color-coded status line for Claude Code CLI that shows context window usage, rate limits, project info, and git branch.

## What It Does

A single Node.js script (`status-line.js`) that runs as a Claude Code StatusLine hook. On every streaming update it:

- Receives live `context_window` and `rate_limits` data from Claude Code
- Writes per-session metrics to disk (context %, token counts, session/weekly usage, `last_interaction_time`)
- Displays a color-coded status bar in the terminal

Fully self-contained — single file, no dependencies.

## Status Line

```
◆ Opus │ ▪ my-project │ ⎇ main │ ◷ 14:32 │ ███▄░░░░░░ 34% (57K/167K) │ 42% ↻2h │ 15% ⟳1d1h
```

- Model name
- Project directory
- Git branch
- Last interaction time
- Context usage bar with percentage and token counts
- 5-hour session usage with reset countdown
- 7-day weekly usage with reset countdown

Colors: green (ok) → yellow (60K+ tokens) → orange (80K+ tokens). Rate limits get red at >80%.

## Quick Install

```bash
git clone https://github.com/anthropics/claude-code-status-line.git
cd claude-code-status-line
bash install.sh
```

The installer will:
- Copy `status-line.js` to `~/.claude/hooks/`
- Patch `~/.claude/settings.json` (with backup)

Then **restart Claude Code**.

## Manual Install

### Step 1: Copy script

```bash
mkdir -p ~/.claude/hooks
cp status-line.js ~/.claude/hooks/
chmod +x ~/.claude/hooks/status-line.js
```

### Step 2: Edit `~/.claude/settings.json`

Add or merge the following into your existing settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "node ~/.claude/hooks/status-line.js",
    "padding": 0
  }
}
```

### Step 3: Restart Claude Code

Quit and reopen, or start a new session. Verify with `/hooks`.

## Configuration

### Token thresholds

Defined in `status-line.js`:

```javascript
const AUTOCOMPACT_BUFFER_TOKENS = 33_000;  // Claude Code reserves this; subtracted from raw window
const WARN_TOKENS = 60_000;                // status turns yellow/warning
const COMPACT_TOKENS = 80_000;             // status turns orange/danger
```

## Metrics File

Writes `metrics-{session_id}.json` to `$TMPDIR/claude-code-compact-guard/` (override with `COMPACT_GUARD_TMPDIR` env var). Contains context %, tokens, rate limits, `last_interaction_time`. Other tools can read these metrics for their own purposes.

## Uninstall

```bash
rm ~/.claude/hooks/status-line.js
```

Then remove the `statusLine` entry from `~/.claude/settings.json`.

## Commands

```bash
# Run tests
node --test tests/test_status_line.js

# Install
bash install.sh
```
