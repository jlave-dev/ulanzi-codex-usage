# Ulanzi Codex Usage Display

This project shows today's Codex token cost and token count on a Ulanzi TC001 running AWTRIX NG. A Mac reads its local Codex usage with `ccusage` and updates two 32×8 screens over the local AWTRIX HTTP API every minute.

The cost screen uses an 8×8 money-with-wings bitmap, a hand-drawn dollar sign, and a compact dollar value. The token screen uses an 8×8 sparkle bitmap and a compact token count. Both icons occupy columns `x=0..7`; both screens start text at `x=10`. The cost value starts at `x=14` after the dollar sign.

## Requirements

- A Ulanzi TC001 with AWTRIX NG installed
- macOS with Node.js, `npx`, `jq`, and `curl`
- Network access from the Mac to the display's HTTP port 80
- Local Codex session data on the Mac

The Mac and display do not need to use the same Wi-Fi band. They must be on networks that can route traffic between them. Guest or IoT client isolation can block this traffic.

Install the command-line requirements with Homebrew if needed:

```bash
brew install node jq
```

## Set up a new Mac

1. Connect AWTRIX NG to Wi-Fi. Reserve its address in the router, or assign it a stable hostname.
2. Confirm that the Mac can reach it. Replace the example address:

   ```bash
   curl http://192.168.1.50/api/v1/device
   ```

3. Clone this repository and run the installer:

   ```bash
   git clone https://github.com/jlave-dev/ulanzi-codex-usage.git
   cd ulanzi-codex-usage
   ./scripts/install-macos.sh 192.168.1.50
   ```

4. If this is a fresh AWTRIX NG installation, configure the display. This disables the built-in time, date, temperature, humidity, and battery screens. It also enables automatic brightness and a 500 ms fade between the two custom screens:

   ```bash
   ./scripts/configure-display 192.168.1.50
   ```

5. Trigger an immediate update:

   ```bash
   ~/.local/bin/update-awtrix-ccusage
   ```

The installer creates:

- `~/.local/bin/update-awtrix-ccusage`
- `~/.config/ulanzi-codex-usage/config`
- `~/Library/LaunchAgents/dev.ulanzi-codex-usage.plist`
- `~/Library/Logs/awtrix-ccusage.log`
- `~/Library/Logs/awtrix-ccusage.error.log`

The LaunchAgent runs once at login and every 60 seconds afterward. Each update replaces both custom apps without an expiration, so the last values remain visible if the updater stops.

## What data it shows

The updater runs:

```bash
npx --yes ccusage@20.0.20 codex daily --last 1 --json --offline
```

It reads `.daily[-1].costUSD` and `.daily[-1].totalTokens`. These values come from Codex data on the computer that runs the updater. Moving the updater to another computer does not move or combine the old computer's usage history.

Large values are shortened to fit the 32-pixel display. For example, `$12345` becomes `$12.3k`, and `58353665` tokens becomes `58.4m`.

## Change the display address

Edit the config file:

```bash
vi ~/.config/ulanzi-codex-usage/config
```

Set the new address without `http://`:

```text
AWTRIX_HOST=192.168.1.50
```

Then restart the LaunchAgent:

```bash
launchctl kickstart -k "gui/$(id -u)/dev.ulanzi-codex-usage"
```

You can also override the config for one run:

```bash
AWTRIX_HOST=awtrix.local ./scripts/update-awtrix-ccusage
```

## Validate and troubleshoot

Run the formatter checks without contacting the display:

```bash
./scripts/update-awtrix-ccusage --self-test
```

Inspect service state and logs:

```bash
launchctl print "gui/$(id -u)/dev.ulanzi-codex-usage"
tail -n 50 ~/Library/Logs/awtrix-ccusage.error.log
tail -n 50 ~/Library/Logs/awtrix-ccusage.log
```

`curl: (28)` means that the display did not answer before the timeout. Check that it is powered on, confirm its current address, and check router isolation rules.

If `ccusage` reports no data, run the command from the **What data it shows** section. Confirm that Codex has local session data for today under the same macOS user account.

If the display changes screens without a visible transition, check the AWTRIX setting. It should report `transitionEffect: Fade`, `transitionDurationMs: 500`, and `autoTransition: true`.

## Remove the macOS service

```bash
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/dev.ulanzi-codex-usage.plist
rm ~/Library/LaunchAgents/dev.ulanzi-codex-usage.plist
rm ~/.local/bin/update-awtrix-ccusage
rm -r ~/.config/ulanzi-codex-usage
```

These commands do not change the display firmware or its saved settings.

## Security

Keep the AWTRIX HTTP API on a trusted local network. Do not forward TCP port 80 from the Internet. Prefer an isolated IoT network that allows only the updater computer to reach the display. The display does not need Internet access for this integration.

## Firmware and recovery

[Firmware setup and recovery](docs/device-recovery.md) explains how to install AWTRIX NG and how to prepare a private factory backup. Raw firmware backups are intentionally excluded because they can contain device identifiers and saved configuration.

The AWTRIX API reference is maintained in the [AWTRIX NG project](https://github.com/Blueforcer/awtrix-ng) and its [HTTP API documentation](https://blueforcer.github.io/awtrix-ng/reference/http/).
