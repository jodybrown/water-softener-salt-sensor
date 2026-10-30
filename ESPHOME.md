# Water Softener Salt Sensor — ESPHome

ESPHome configuration for a JSN-SR04T ultrasonic water softener salt level sensor using an ELEGOO ESP32 DevKit. Reports distance to salt surface, calculates salt level %, and emits a low-salt alert binary sensor.

## Files

| File | Purpose |
|------|---------|
| `water-softener-salt-sensor.yaml` | ESPHome configuration |
| `base.scad` / `lid.scad` | OpenSCAD models for 3D-printed housing |
| `README.md` | This file |

## Hardware

| Component | Notes |
|-----------|-------|
| Microcontroller | ELEGOO ESP32 DevKit (CP2102 USB-UART) |
| Ultrasonic sensor | JSN-SR04T (waterproof, ~5V logic) |
| Power | 5V from USB or external supply |

### ⚠️ Voltage Divider Required (Critical)

The JSN-SR04T **Echo** pin outputs 5V. The ESP32 GPIO pins are **not 5V tolerant** — connecting Echo directly will damage the ESP32.

Wire a voltage divider on the Echo pin:

```
JSN-SR04T Echo ──[1kΩ]──┬── ESP32 GPIO 18
                        │
                       [2kΩ]
                        │
                       GND
```

This steps the 5V Echo signal down to ~3.3V, safe for the ESP32.

### Wiring Table

| JSN-SR04T Pin | Connect to | Notes |
|---------------|------------|-------|
| VCC | 5V | From USB or external supply |
| GND | GND | Common with ESP32 |
| Trig | GPIO 5 | Direct — 3.3V is enough to trigger |
| Echo | Voltage divider → GPIO 18 | 1kΩ + 2kΩ divider required |

### ESP32 Power

Power the ESP32 from the same 5V supply via its **5V/VIN pin** or USB. Make sure GND is shared between the ESP32 and the sensor.

## Installation

### 1. Install ESPHome Add-on

In Home Assistant:
1. **Settings → Add-ons → Add-on Store**
2. Search for **ESPHome** and install it
3. Start the add-on
4. Click **Open Web UI** (or navigate to `http://homeassistant.local:6052`)

### 2. Add the Configuration

1. In the ESPHome dashboard, click **+ New Device**
2. Name it `water-softener-salt-sensor`
3. Choose **ESP32** as the board type
4. Copy the contents of `water-softener-salt-sensor.yaml` into the config editor
5. Click **Save**

### 3. Configure Secrets

The YAML uses `!secret` for sensitive values. In the ESPHome web UI:
1. Click the **Secrets** tab
2. Add the following:
   - `wifi_ssid` — your WiFi network name
   - `wifi_password` — your WiFi password
   - `api_key` — API encryption key (any random string)
   - `fallback_password` — fallback AP password (any random string)

### 4. Compile and Flash

1. Click **Install** on the `water-softener-salt-sensor` device
2. Choose **USB** and select your ESP32's serial port
3. Wait for compilation and flashing to complete
4. Unplug and replug the ESP32 to reboot

The device will create a fallback hotspot named `wsss-fallback` if it can't connect to your WiFi.

### 5. Enable in Home Assistant

1. Home Assistant should discover the ESPHome device automatically
2. Go to **Settings → Devices & Services**
3. Look for the `water-softener-salt-sensor` integration and click **Configure**
4. Enable the integration

---

## Alternate Installation — ESPHome Desktop Client

Instead of the Home Assistant add-on, you can use the standalone ESPHome desktop client:

### 1. Install the Desktop Client

1. Download from https://esphome.io/install/
2. Available for Windows, macOS, and Linux
3. Install and launch the application

### 2. Add the Configuration

1. Click **New Device** → name it `water-softener-salt-sensor`
2. Choose **ESP32** as the board type
3. Copy the contents of `water-softener-salt-sensor.yaml` into the config editor
4. Click **Save**

### 3. Configure Secrets

In the desktop client, click **Secrets** and add:

| Secret | Value |
|--------|-------|
| `wifi_ssid` | Your WiFi network name |
| `wifi_password` | Your WiFi password |
| `api_key` | Any random string (API encryption key) |
| `fallback_password` | Any random string (fallback AP password) |

### 4. Compile and Flash

1. Connect the ESP32 to your computer via USB
2. Click **Install** → choose **USB** → select the ESP32 serial port
3. Wait for compilation and flashing to complete
4. Unplug and replug the ESP32 to reboot

The device will create a fallback hotspot named `wsss-fallback` if it can't connect to your WiFi.

### 5. Enable in Home Assistant

1. Home Assistant should discover the ESPHome device automatically
2. Go to **Settings → Devices & Services**
3. Look for the `water-softener-salt-sensor` integration and click **Configure**
4. Enable the integration

Entities created:
- `sensor.softener_salt_distance` — distance to salt surface (m)
- `sensor.softener_salt_level` — estimated salt level (%)
- `binary_sensor.softener_salt_low` — low salt alert

## Calibration

The template sensors use `min_dist` and `max_dist` values that you must adjust for your tank:

```yaml
float min_dist = 0.1;  // m — distance when tank is FULL of salt
float max_dist = 0.8;  // m — distance when tank is EMPTY
```

### How to measure:

1. **Fill the tank with salt** — note the `sensor.softener_salt_distance` reading → this is your `min_dist`
2. **Run the tank low (or measure to the bottom)** — note the reading → this is your `max_dist`
3. Edit the YAML and update both values
4. Click **Install** to push the updated config

### Low-salt threshold:

```yaml
return id(softener_salt_distance).state > 0.6;  // adjust threshold (m)
```

Set this to a distance that corresponds to "salt getting low" in your tank.

## Mounting

1. Print `base.stl`, `lid.stl`, and `wedge.stl` (PETG recommended for humidity resistance). You can also use `water-softener-salt-sensor-box.3mf`.
2. Mount the housing on the **outside** of the tank lid
3. Drill a hole through the lid (~25mm / 1") for the ultrasonic beam
4. Stack the wedge and base together and fasten them to the lid through the 4 corner mounting holes (4 screws)
5. Mount the ESP32 in the base (4 screws)
6. Place the JSN-SR04T PCB on the platform inside the tower and mount it in the base (4 screws)
7. Route the sensor cable to the ESP32 board inside the base
8. Route the USB/power cable out through the side exit hole
9. Secure the lid to the base with 4 screws into the corner bosses (16 screws total)

## Maintenance

- The JSN-SR04T transducer is waterproof but the ESP32 board is not — keep it inside the sealed enclosure
- Consider conformal coating the ESP32 board for extra humidity protection
- Salt dust is corrosive — wipe the housing occasionally if dust accumulates

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Distance reads 0 or very high | Beam hole blocked or transducer misaligned | Check hole through lid is clear, transducer pointing straight down |
| Distance jumps around | Salt surface uneven or noisy readings | Median filter is already applied; increase `window_size` if needed |
| Device won't connect to WiFi | Wrong credentials or weak signal | Check secrets, move closer to AP, or use fallback hotspot |
| Echo pin damages ESP32 | Missing voltage divider | Add 1kΩ + 2kΩ divider on Echo → GPIO 18 |
| Salt level % seems wrong | min_dist / max_dist not calibrated | Measure actual full/empty distances and update YAML |

## ESPHome Logs

View logs in the ESPHome web UI:
1. Select `water-softener-salt-sensor` device
2. Click **Logs**
3. Watch for WiFi connection, API connection, and sensor readings

## License

Personal use. Modify as needed for your setup.