# Agent Instructions

## Scope

This repository owns the local `ccusage` to AWTRIX NG bridge for a Ulanzi TC001. Read `README.md` before changing setup behavior. Read `docs/device-recovery.md` before any firmware work.

## Supported path

- `scripts/update-awtrix-ccusage` is the source of truth for data collection, formatting, icons, and AWTRIX NG payloads.
- `scripts/install-macos.sh` installs the updater, writes the host config, and creates the LaunchAgent.
- `scripts/configure-display` sets the AWTRIX NG app order, enables automatic brightness, and configures a 500 ms fade between apps.
- Keep the updater address in `~/.config/ulanzi-codex-usage/config`. Do not commit a private network address as a working default.
- Keep `ccusage` pinned unless a tested schema or compatibility change requires an update.

## Validation

Run these checks from the repository root after script changes:

```bash
zsh -n scripts/update-awtrix-ccusage scripts/install-macos.sh scripts/configure-display
./scripts/update-awtrix-ccusage --self-test
```

When the user authorizes live-device validation, set `AWTRIX_HOST` explicitly and run one update. Confirm `/api/v1/apps` contains `ccusage` and `tokens`. Do not treat a successful self-test as network or display proof.

## Display constraints

- The matrix is 32×8 pixels.
- Keep formatted cost and token values at five characters or fewer.
- Preserve the explicit dollar-sign drawing. The built-in font dollar sign rendered poorly on this display.
- Preserve the money-with-wings cost bitmap and sparkle token bitmap unless the user requests a new visual design.
- The cost label begins at `x=12`; its numeric value begins at `x=16` after the custom dollar sign. The token text begins at `x=12`.
- Preserve the text baseline at `y=1` unless a physical-device check supports a change.
- Do not add an app expiration field. The display should keep the last values visible if the updater is temporarily stopped.
- Keep only the cost and token custom apps in the normal loop.

## Safety

- Never expose the AWTRIX HTTP API to the public Internet.
- Never commit Wi-Fi credentials, local session data, or secrets.
- Do not flash firmware, erase settings, reboot the display, or restore a backup without explicit user authorization.
- Never commit raw device firmware backups. They can contain unique identifiers, Wi-Fi configuration, or other private state.
- Before a restore, identify the current serial port, verify the private backup hash, and confirm the target chip and flash size.

## Git

Use Conventional Commits. Keep generated logs and local config out of Git.
