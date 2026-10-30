# Water Softener Salt Sensor

ESPHome-based salt level monitor for a water softener using a JSN-SR04T ultrasonic sensor and an ESP32. It reports the distance to the salt surface, estimates remaining salt percentage, and provides a low-salt alert in Home Assistant. Includes OpenSCAD/STL files for a 3D-printed, angled housing designed to mount to a sloped tank lid.

Posted on Maker World at https://makerworld.com/en/models/3520243-water-softener-salt-sensor

## Features

- **Non-contact sensing** - Uses a waterproof JSN-SR04T ultrasonic sensor
- **Home Assistant integration** - Exposes entities via the ESPHome API
- **Noise reduction** - Median filtering applied to distance readings
- **Low-salt alerts** - Configurable template binary sensor
- **Custom enclosure** - 2-piece angled housing for mounting to a sloped tank lid

## Hardware

| Component | Notes |
|-----------|-------|
| ESP32 DevKit | Target board for ESPHome |
| JSN-SR04T Ultrasonic Sensor | Waterproof transducer. Echo is 5V and requires a voltage divider. |
| 1kΩ + 2kΩ Resistors | For the Echo pin voltage divider (5V → ~3.3V) |
| 5V Power Supply | Shared between ESP32 and sensor |
| Screws | 4 to mount the wedge and base (stacked) to the lid, 4 to mount the ESP32 in the base, 4 to mount the JSN-SR04T in the base, and 4 to attach the lid to the base (16 total) |

**Wiring:** VCC → 5V, GND shared, Trig → GPIO5 (direct), Echo → (1kΩ/2kΩ divider) → GPIO18. See [ESPHOME.md](ESPHOME.md) for full details.

## Quick Start

1. **Flash the firmware** - Load [`water-softener-salt-sensor.yaml`](water-softener-salt-sensor.yaml) in ESPHome (Home Assistant add-on or desktop). Add the required secrets: `wifi_ssid`, `wifi_password`, `api_key`, `fallback_password`. See [ESPHOME.md](ESPHOME.md) for details.
2. **Print housing** - Print the housing from the provided STLs or 3MF. Regenerate the wedge STL using OpenSCAD if your lid is on an angle that does not match the default (2.7 degrees).
3. **Assemble the base** - Mount the ESP32 and JSN-SR04T Ultrasonic Sensor into the base and route all the wiring.
4. **Calibrate** - *OPTIONAL* - With the tank full of salt, record the `sensor.softener_salt_distance` reading. With the tank low/empty, record another reading. Update `min_dist` and `max_dist` (in meters) in the template sensor. Adjust the low-salt threshold as needed.
5. **Connect to Home Assistant** - After flashing, the device will be discovered via ESPHome. Enable the integration to create its entities.
6. **Mount** - Drill a ~25mm (1") hole through the tank lid for the sensor, drill holes for the screws, mount the wedge and base (stacked), and secure the lid with screws.

## Entities

| Entity | Type | Description |
|--------|------|-------------|
| `sensor.softener_salt_distance` | Sensor (m) | Distance to the salt surface (median filtered, 30s updates) |
| `sensor.softener_salt_level` | Sensor (%) | Estimated salt remaining based on calibrated min/max distances |
| `binary_sensor.softener_salt_low` | Binary sensor | Low-salt alert based on configurable distance threshold |

## Files

| File | Purpose |
|------|---------|
| [`water-softener-salt-sensor.yaml`](water-softener-salt-sensor.yaml) | ESPHome configuration |
| [`ESPHOME.md`](ESPHOME.md) | Detailed wiring, installation, calibration, mounting, and troubleshooting |
| [`base.scad`](base.scad), [`lid.scad`](lid.scad), [`wedge.scad`](wedge.scad) | OpenSCAD housing models |
| [`base.stl`](base.stl), [`lid.stl`](lid.stl), [`wedge.stl`](wedge.stl) | Ready-to-print STL models |
| [`water-softener-salt-sensor.3mf`](water-softener-salt-sensor.3mf) | Ready-to-print 3MF model (contains all STL models) |

## Important Notes

- **Voltage divider required** - Never connect the JSN-SR04T Echo pin directly to the ESP32. Use a 1kΩ/2kΩ voltage divider on GPIO18.
- **Keep electronics dry** - The JSN-SR04T transducer is waterproof, but the ESP32 is not. Keep it sealed inside the enclosure.
- **Calibrate per tank** - Default values (`min_dist = 0.1 m`, `max_dist = 0.8 m`, low threshold `> 0.6 m`) are placeholders and must be tuned to your brine tank.

## License

[CC0 1.0 Universal](LICENSE.md) - This work is dedicated to the public domain. Anyone can use, modify, distribute, or build upon it for any purpose, with no restrictions.

*This project was created with assistance from [OpenCode](https://github.com/opencode-ai/opencode).*
