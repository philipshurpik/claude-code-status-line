# Claude Code Status Line - Windows installer
# Copies status-line.js to ~/.claude/ and patches settings.json
# Optionally installs the handoff command

$ErrorActionPreference = "Stop"

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SettingsFile = Join-Path $ClaudeDir "settings.json"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Claude Code Status Line Installer ==="
Write-Host ""
Write-Host "What would you like to install?"
Write-Host "  1) Status line only"
Write-Host "  2) Status line + /handoff command"
Write-Host ""
$choice = Read-Host "Choose [1/2] (default: 2)"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "2" }

# Copy status line script
Copy-Item (Join-Path $ScriptDir "status-line.js") (Join-Path $ClaudeDir "status-line.js") -Force
Write-Host "Copied status-line.js to $ClaudeDir"

# Ensure settings.json exists
if (-not (Test-Path $SettingsFile)) {
    Set-Content -Path $SettingsFile -Value "{}"
}

# Backup and patch settings.json
$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
Copy-Item $SettingsFile "${SettingsFile}.backup.${timestamp}"

$claudeDirForward = $ClaudeDir -replace '\\', '/'
$jsCode = @"
const fs = require('fs');
const [settingsPath, claudeDir] = process.argv.slice(1);
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
settings.statusLine = {
  type: 'command',
  command: 'node ' + claudeDir + '/status-line.js',
  padding: 0,
};
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
"@
node -e $jsCode "$SettingsFile" "$claudeDirForward"

Write-Host "Updated $SettingsFile (backup saved)"

# Install handoff command if selected
if ($choice -eq "2") {
    $commandsDir = Join-Path $ClaudeDir "commands"
    if (-not (Test-Path $commandsDir)) {
        New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
    }
    Copy-Item (Join-Path $ScriptDir "commands\handoff.md") (Join-Path $commandsDir "handoff.md") -Force
    Write-Host "Copied handoff.md to $commandsDir"
}

Write-Host ""
Write-Host "Done! Status line will appear in your next Claude Code interaction."
if ($choice -eq "2") {
    Write-Host "Use /handoff in Claude Code to create a handoff document."
}
