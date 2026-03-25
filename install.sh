#!/bin/bash
set -euo pipefail

# Claude Code Status Line - installer
# Copies status-line.js to ~/.claude/ and patches settings.json

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code Status Line Installer ==="
echo ""

# 1. Copy script
cp "$SCRIPT_DIR/status-line.js" "$CLAUDE_DIR/status-line.js"
chmod +x "$CLAUDE_DIR/status-line.js"
echo "✓ Copied status-line.js to $CLAUDE_DIR"

# 2. Patch settings.json
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
    echo "✓ Created $SETTINGS_FILE"
fi

# Backup existing settings
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%s)"
echo "✓ Backed up settings.json"

# Use Python to merge settings (available everywhere Claude Code runs)
python3 - "$SETTINGS_FILE" "$CLAUDE_DIR" <<'PYTHON_SCRIPT'
import json
import sys

settings_path = sys.argv[1]
claude_dir = sys.argv[2]

with open(settings_path) as f:
    settings = json.load(f)

# Add StatusLine
settings['statusLine'] = {
    'type': 'command',
    'command': f'node {claude_dir}/status-line.js',
    'padding': 0,
}
print('  + Set statusLine -> status-line.js')

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)

PYTHON_SCRIPT

echo ""
echo "✓ Updated $SETTINGS_FILE"

echo ""
echo "=== Done! ==="
echo ""
echo "Installed:"
echo "  - StatusLine: context % with color coding, rate limits, project/branch info"
echo ""
echo "To customize thresholds, edit:"
echo "  $CLAUDE_DIR/status-line.js (WARN_TOKENS, COMPACT_TOKENS)"
echo ""
echo "⚠️  Restart Claude Code for changes to take effect."
