#!/bin/sh
# Builds edge-warp, installs it to ~/.local/bin and starts it at every login (LaunchAgent local.edge-warp).
# ./install.sh --uninstall stops it and removes it.
set -e
cd "$(dirname "$0")"
BIN="$HOME/.local/bin/edge-warp"
PLIST="$HOME/Library/LaunchAgents/local.edge-warp.plist"
launchctl bootout "gui/$(id -u)/local.edge-warp" 2>/dev/null || true
if [ "$1" = "--uninstall" ]; then
  rm -f "$BIN" "$PLIST"
  echo "edge-warp removed"
  exit 0
fi
mkdir -p "$HOME/.local/bin" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
swiftc -O -o "$BIN" edge-warp.swift
cat > "$PLIST" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.edge-warp</string>
  <key>ProgramArguments</key><array><string>$BIN</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ProcessType</key><string>Interactive</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/edge-warp.log</string>
</dict>
</plist>
P
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "edge-warp installed and running (log: ~/Library/Logs/edge-warp.log)"
