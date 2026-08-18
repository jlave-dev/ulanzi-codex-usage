# Firmware Setup and Recovery

The updater requires a Ulanzi TC001 running AWTRIX NG. Firmware installation is separate from the computer setup in the root `README.md`.

## Install AWTRIX NG

Use the [official AWTRIX NG flasher](https://blueforcer.github.io/awtrix-ng/flasher/) in Chrome, Edge, or Opera. For a TC001, select the classic ESP32 4 MB image.

After flashing:

1. Connect temporarily to the AWTRIX NG setup access point.
2. Open the setup page shown by the access point, or browse to `http://192.168.4.1`.
3. Configure the display for the local Wi-Fi network.
4. Reserve the display address in the router or assign it a stable hostname.
5. Follow the root `README.md` to install the updater.

Do not expose the AWTRIX HTTP API to the Internet.

## Back up factory firmware first

If the clock still has its factory firmware, make a private full-flash backup before installing AWTRIX NG. Do not commit the backup to a public repository. It can contain unique device identifiers, Wi-Fi configuration, or other saved state.

Install Espressif's flash tool on macOS:

```bash
brew install esptool
```

Connect the TC001 with a data-capable USB-C cable. Find its current serial port:

```bash
ls /dev/cu.*
```

Inspect the chip and flash size before reading it:

```bash
TC001_PORT=/dev/cu.usbserial-EXAMPLE
esptool --chip esp32 --port "$TC001_PORT" flash-id
```

Use the flash size reported by that command. For a 4 MB device, make two complete reads and compare them:

```bash
esptool --chip esp32 --port "$TC001_PORT" read-flash 0x0 0x400000 tc001-factory-1.bin
esptool --chip esp32 --port "$TC001_PORT" read-flash 0x0 0x400000 tc001-factory-2.bin
shasum -a 256 tc001-factory-1.bin tc001-factory-2.bin
```

Factory firmware can update writable state between boots, so full-image hashes can differ. Keep both reads and record their hashes in private storage.

## Restore a private backup

Restoring firmware erases AWTRIX NG and all settings. Confirm the target device, flash size, serial port, and backup hash before starting.

For a verified 4 MB backup:

```bash
TC001_PORT=/dev/cu.usbserial-EXAMPLE
esptool --chip esp32 --port "$TC001_PORT" erase-flash
esptool --chip esp32 --port "$TC001_PORT" --baud 460800 \
  write-flash --flash-size 4MB 0x0 tc001-factory-1.bin
esptool --chip esp32 --port "$TC001_PORT" --baud 460800 \
  verify-flash 0x0 tc001-factory-1.bin
```

Never restore a backup from one TC001 to another device.
