#!/bin/bash
set -euo pipefail

# Claude Code Status Line - installer
# Copies status-line.js to ~/.claude/ and patches settings.json
# Optionally installs the handoff command

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code Status Line Installer ==="
echo ""
echo "What would you like to install?"
echo "  1) Status line only"
echo "  2) Status line + /handoff command"
echo ""
read -rp "Choose [1/2] (default: 2): " choice
choice="${choice:-2}"

# Copy status line script
cp "$SCRIPT_DIR/status-line.js" "$CLAUDE_DIR/status-line.js"
echo "✓ Copied status-line.js to $CLAUDE_DIR"

# Ensure settings.json exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Backup and patch settings.json
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%s)"

node -e "
const fs = require('fs');
const [settingsPath, claudeDir] = process.argv.slice(1);
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
settings.statusLine = {
  type: 'command',
  command: 'node ' + claudeDir + '/status-line.js',
  padding: 0,
};
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
" "$SETTINGS_FILE" "$CLAUDE_DIR"

echo "✓ Updated $SETTINGS_FILE (backup saved)"

# Install handoff command if selected
if [ "$choice" = "2" ]; then
    mkdir -p "$CLAUDE_DIR/commands"
    cp "$SCRIPT_DIR/commands/handoff.md" "$CLAUDE_DIR/commands/handoff.md"
    echo "✓ Copied handoff.md to $CLAUDE_DIR/commands/"
fi

echo ""
echo "Done! Status line will appear in your next Claude Code interaction."
if [ "$choice" = "2" ]; then
    echo "Use /handoff in Claude Code to create a handoff document."
fi