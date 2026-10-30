
// ── Parameters ──────────────────────────────────────────────
wedge_angle = 2.7; // tank lid slope (8mm over 170mm)

// Box dimensions
base_l = 130; // length (mm)
base_w = 70; // width (mm)
base_wall = 3; // wall thickness (mm)
min_thickness = 3; // min thickness (mm)
max_thickness = 25; // max thickness (mm)

// ── screw_holes
screw_hole_offset = 12; // how far from edge (mm)
screw_hole_d = 3.5; // diameter of hole for screws (mm)

// Position bosses inset from interior cavity corners (moved inward for better screw placement)
screw_hole_x = base_l / 2 - base_wall - screw_hole_offset / 2;
screw_hole_y = base_w / 2 - base_wall - screw_hole_offset / 2;

// ── sensor hole ──────────────────────────────────────────
sensor_insert_d = 22; // sensor insert diameter (mm)
sensor_hole_d = sensor_insert_d * 1.5; // sensor flange diameter for hole through floor (mm)
sensor_hole_x = -sensor_insert_d / 2; // position of hole through floor (mm)


difference() {

  // step 1 - create a box with a wedge cut out of the bottom
  cube([base_l, base_w, max_thickness], center=true);

  // step 2 - cut out a wedge from the bottom of the box
  translate([base_l/2, 0, min_thickness / 2])
    rotate([0, wedge_angle, 0])
      cube([base_l * 4, base_w * 4, max_thickness], center=true);

  // step 3 - cut out the boss holes (go all the way through entire model)
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * screw_hole_x, y * screw_hole_y, 0])
      cylinder(h=max_thickness * 2, d=screw_hole_d, center=true, $fn=32);
  }

  // Bottom sensor hole
  translate([sensor_hole_x, 0, 0])
    cylinder(h=max_thickness * 2, d=sensor_hole_d, center=true, $fn=64);


}
