# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A color-coded status line for Claude Code CLI. Single Node.js script (`status-line.js`) that runs as a StatusLine hook — receives live `context_window` and `rate_limits` data on every streaming update, writes per-session metrics to disk, and displays a color-coded status bar in the terminal.

Fully self-contained, no dependencies. Only fires in CLI mode — does NOT fire when using VS Code/Cursor extension.

## Architecture

```
Claude Code CLI
    └─► StatusLine hook (status-line.js)   fires on every token stream update
            writes: metrics-{session_id}.json  (context %, tokens, rate limits, last_interaction_time)
            prints: colored status bar → stdout → Claude Code displays it
```

**Token thresholds** (defined in status-line.js):
- `AUTOCOMPACT_BUFFER_TOKENS` = 33K — Claude Code reserves this for autocompact; subtracted from raw window to get effective window size
- `WARN_TOKENS` = 60K — status turns yellow/warning
- `COMPACT_TOKENS` = 80K — status turns orange/danger

## Commands

```bash
# Run tests
node --test tests/test_status_line.js

# Install
bash install.sh
```

## Testing Approach

- JS tests (`tests/test_status_line.js`): use `node:test` (no deps), run StatusLine hook via `execFileSync`.
- CI: GitHub Actions on push/PR to main — Node 20.

## Metrics File

Written to `$TMPDIR/claude-code-compact-guard/metrics-{session_id}.json` (override with `COMPACT_GUARD_TMPDIR` env var). Contains context %, tokens, rate limits, last_interaction_time. Other tools (e.g. compact-guard extension) can read these metrics.
