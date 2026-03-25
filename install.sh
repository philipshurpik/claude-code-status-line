#!/bin/bash
set -euo pipefail

# Claude Code Status Line - installer
# Copies status-line.js to ~/.claude/ and patches settings.json

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code Status Line Installer ==="

# Copy script
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
echo ""
echo "Done! Status line will appear in your next Claude Code interaction."
