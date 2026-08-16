#!/bin/zsh
set -eu

if [[ $# -ne 1 || $1 == -* ]]; then
  print -u2 "Usage: $0 AWTRIX_HOST"
  print -u2 "Example: $0 192.168.1.50"
  exit 2
fi

AWTRIX_HOST=$1
if [[ $AWTRIX_HOST == *[^A-Za-z0-9._:-]* ]]; then
  print -u2 'AWTRIX_HOST must be an IP address or hostname without a URL scheme.'
  exit 2
fi

for command in npx jq curl plutil; do
  if ! command -v "$command" >/dev/null; then
    print -u2 "Missing required command: $command"
    exit 1
  fi
done

repo_dir=${0:A:h:h}
bin_dir="$HOME/.local/bin"
config_dir="$HOME/.config/ulanzi-codex-usage"
agent_dir="$HOME/Library/LaunchAgents"
log_dir="$HOME/Library/Logs"
program="$bin_dir/update-awtrix-ccusage"
config="$config_dir/config"
plist="$agent_dir/dev.ulanzi-codex-usage.plist"

mkdir -p "$bin_dir" "$config_dir" "$agent_dir" "$log_dir"
install -m 755 "$repo_dir/scripts/update-awtrix-ccusage" "$program"
printf 'AWTRIX_HOST=%s\n' "$AWTRIX_HOST" > "$config"
chmod 600 "$config"

plutil -create xml1 "$plist"
plutil -insert Label -string dev.ulanzi-codex-usage "$plist"
plutil -insert ProgramArguments -array "$plist"
plutil -insert ProgramArguments.0 -string "$program" "$plist"
plutil -insert EnvironmentVariables -dictionary "$plist"
plutil -insert EnvironmentVariables.AWTRIX_CONFIG -string "$config" "$plist"
plutil -insert RunAtLoad -bool true "$plist"
plutil -insert StartInterval -integer 60 "$plist"
plutil -insert StandardOutPath -string "$log_dir/awtrix-ccusage.log" "$plist"
plutil -insert StandardErrorPath -string "$log_dir/awtrix-ccusage.error.log" "$plist"
plutil -lint "$plist"

"$program" --self-test
launchctl bootout "gui/$(id -u)" "$plist" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$plist"

print "Installed updater for $AWTRIX_HOST."
print "The first update can take longer while npx downloads ccusage."
print "Logs: $log_dir/awtrix-ccusage.log"
