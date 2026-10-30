// Water Softener Salt Sensor Housing - Base Unit
// Box with angled bottom, empty interior, lid mounts on top

// ── Parameters ──────────────────────────────────────────────
lid_angle = 2.7; // tank lid slope (8mm over 170mm)

// Box dimensions
base_l = 130; // length (mm)
base_w = 70; // width (mm)
base_h = 55; // height (mm) — deep enough for angled floor min thickness
base_wall = 3; // wall thickness (mm)
floor_thickness = 3; // floor thickness (mm)

// Rebate at top rim for lid to countersink into
rebate_d = 2; // rebate depth (mm)
rebate_w = 3; // rebate width (mm)

// Cable exit hole in side wall
cable_wall_hole_d = 20;

// ── sensor hole ──────────────────────────────────────────
sensor_hole_d = 22; // sensor diameter for hole through floor (mm)
sensor_hole_x = -sensor_hole_d / 2; // sensor position on x axis (mm)

// ── Bosses (for lid screws, anchored in corners) ─────────────
boss_d = 5; // boss outer diameter (mm)
boss_h = base_h - floor_thickness - rebate_d; // 74;     // boss height above floor (mm)
boss_depth = floor_thickness; // boss embeds into floor this far
screw_d = 3.5; // boss screw hole diameter (mm)

// Position bosses inset from interior cavity corners (moved inward for better screw placement)
boss_overlap = -3.5; // negative = inset from corner wall edge
boss_x = base_l / 2 - base_wall - boss_d / 2 + boss_overlap;
boss_y = base_w / 2 - base_wall - boss_d / 2 + boss_overlap;

// ── ESP32 Mounting Standoffs (bottom of base cavity) ─────────
esp32_standoff_d = 5.5; // standoff outer diameter (mm)
esp32_standoff_h = 30; // standoff height above floor (mm)
esp32_standoff_screw_d = 2.5; // screw hole diameter (mm)
esp32_standoff_depth = floor_thickness; // embeds into floor

// Position standoffs on right side of cavity (away from tower at left)
esp32_x_diff = 46; // distance beterween center of screw holes on x axis
esp32_y_diff = 23.5; // distance between center of screw holes on y axis
esp32_x1 = 13.5; // left column of standoffs
esp32_x2 = esp32_x1 + esp32_x_diff; // right column of standoffs
esp32_y = esp32_y_diff / 2; // row offset from center

// hole for the usb connector for the esp32
esp32_plug_h = 4;
esp32_plug_w = 10;
esp32_plug_d = 2;

// ── sensor board Mounting Standoffs (bottom of base cavity) ─────────
sensorboard_standoff_d = 5.5; // standoff outer diameter (mm)
sensorboard_standoff_h = 35; // standoff height above floor (mm)
sensorboard_standoff_screw_d = 2.5; // screw hole diameter (mm)
sensorboard_standoff_depth = floor_thickness; // embeds into floor

// Position standoffs on right side of cavity (away from tower at left)
sensorboard_x_diff = 24; // distance beterween center of screw holes on x axis
sensorboard_y_diff = 36; // distance between center of screw holes on y axis
sensorboard_x1 = -20; // left column of standoffs
sensorboard_x2 = sensorboard_x1 - sensorboard_x_diff; // right column of standoffs
sensorboard_y = sensorboard_y_diff / 2; // row offset from center

// outside corner fillets

fillet_size = 10; // the square-ish size, p
fillet_r = 3; // exterior corner fillet radius (mm)
fillet_offset = 2.2; // for debugging the fillets
fillet_x = base_l / 2 - fillet_size / 2 + fillet_offset; // pos-x
fillet_y = base_w / 2 - fillet_size / 2 + fillet_offset; // pos-y

// ── Base module ─────────────────────────────────────────────
module base() {
  difference() {
    union() {

      // Step 1: Create empty box
      difference() {

        cube([base_l, base_w, base_h], center=true);

        // Cut interior cavity
        translate([0, 0, floor_thickness])
          cube([base_l - base_wall * 2, base_w - base_wall * 2, base_h], center=true);

        // subtract fillet
        fillet();
      }

      // Create bosses (anchored in corners)
      for (x = [-1, 1], y = [-1, 1]) {
        translate(
          [
            x * boss_x,
            y * boss_y,
            -base_h / 2 + floor_thickness - boss_depth / 2 + boss_h / 2,
          ]
        )
          boss_body();
      }

      // Create ESP32 mounting standoffs
      for (x = [esp32_x1, esp32_x2], y = [-esp32_y, esp32_y]) {
        translate([x, y, -base_h / 2 + floor_thickness - esp32_standoff_depth / 2 + esp32_standoff_h / 2])
          esp32_standoff_body();
      }

      // Create sensor board mounting standoffs
      for (x = [sensorboard_x1, sensorboard_x2], y = [-sensorboard_y, sensorboard_y]) {
        translate([x, y, -base_h / 2 + floor_thickness - sensorboard_standoff_depth / 2 + sensorboard_standoff_h / 2])
          sensorboard_standoff_body();
      }
    }

    // Bottom sensor hole
    translate([sensor_hole_x, 0, 0])
      cylinder(h=base_h * 2, d=sensor_hole_d, center=true, $fn=64);

    // Cable exit hole
    translate([base_l / 2, 0, -base_h / 2 + esp32_standoff_h + floor_thickness + 3])
      cube([10, esp32_plug_w, esp32_plug_h], center=true);

    // Boss floor holes (go all the way through entire model)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * boss_x, y * boss_y, 0])
        cylinder(h=base_h * 4, d=screw_d, center=true, $fn=32);
    }
  }
}

// Boss body (used inside difference union)
module boss_body() {
  difference() {
    cylinder(h=boss_h + boss_depth, d=boss_d * 3, center=true, $fn=32);
    cylinder(h=boss_h + boss_depth, d=screw_d, center=true, $fn=32);
  }
}

// ESP32 standoff body (used inside difference union)
module esp32_standoff_body() {
  difference() {
    cylinder(h=esp32_standoff_h + esp32_standoff_depth, d=esp32_standoff_d, center=true, $fn=32);
    cylinder(h=esp32_standoff_h + esp32_standoff_depth + 0.1, d=esp32_standoff_screw_d, center=true, $fn=32);
  }
}

// sensor board standoff body (used inside difference union)
module sensorboard_standoff_body() {
  difference() {
    cylinder(h=sensorboard_standoff_h + sensorboard_standoff_depth, d=sensorboard_standoff_d, center=true, $fn=32);
    cylinder(h=sensorboard_standoff_h + sensorboard_standoff_depth + 0.1, d=sensorboard_standoff_screw_d, center=true, $fn=32);
  }
}
module fillet() {

  for (x = [-1, 1], y = [-1, 1]) {
    translate([fillet_x * x, fillet_y * y, 0])
      difference() {

        // cube that will be the fillet cutter
        translate([x, y, 0])
          cube([fillet_size / 2, fillet_size / 2, base_h + fillet_size], center=true);

        // cylinder to cut rounded edge from the cube
        cylinder(h=base_h + fillet_size + 50, r=fillet_r, center=true, $fn=32);

        // cube 1 to get rid of unwanted corners
        translate([-fillet_r / 2 * x, -fillet_r / 2 * y, 0])
          cube([fillet_size, fillet_size / 2, base_h + fillet_size + 2], center=true);

        // cube to get rid of unwanted corners
        translate([-fillet_r / 2 * x, -fillet_r / 2 * y, 0])
          cube([fillet_size / 2, fillet_size, base_h + fillet_size + 2], center=true);
      }
  }
}

base();

// testing
// fillet();
