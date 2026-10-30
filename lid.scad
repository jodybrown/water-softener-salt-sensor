// Water Softener Salt Sensor Housing - Lid
// Stepped edge: outer part sits on top of base walls, inner part drops into rebate

lid_l = 130; // outer length — matches base exterior (sits on top of walls)
lid_w = 70; // outer width — matches base exterior (sits on top of walls)
lid_inner_l = 122; // inner length — fits inside rebate opening (124mm)
lid_inner_w = 62; // inner width — fits inside rebate opening (64mm)
lid_h = 8; // total thickness (inner part full height)
lid_step_h = 3; // outer step height (sits on top of walls)

// Boss positions (must match base.scad exactly)
base_l = 130;
base_w = 70;
base_wall = 3;
boss_d = 5; // matches base boss_d
boss_overlap = -3.5; // matches base boss_overlap
boss_x = base_l / 2 - base_wall - boss_d / 2 + boss_overlap;
boss_y = base_w / 2 - base_wall - boss_d / 2 + boss_overlap;
screw_d = 3;

fillet_r = 3; // exterior corner fillet radius (mm)

// ── Lid module ──────────────────────────────────────────────
module lid() {

  // Step 1: Create the outer step with rounded exterior edges.
  // Step 2: Add the inner section that drops into the base rebate.
  // Step 3: Cut out the underside to form the lid's recessed interior.
  // Step 4: Add cylindrical bosses around the screw holes.
  // Step 5: Cut the screw holes through the lid and bosses.

  difference() {

    union() {

      difference() {

        union() {
          minkowski() {
            // Cube reduced by twice the fillet radius on each side.
            cube([lid_l - fillet_r * 2, lid_w - fillet_r * 2, lid_step_h], center=true);
            // Use the lower half of a sphere to round the outer edges.
            difference() {
              sphere(r=fillet_r, $fn=32);
              translate([0, 0, fillet_r / 2])
                cube([fillet_r * 2, fillet_r * 2, fillet_r], center=true);
            }
          }

          // ── Step 2: Inner section — drops into the base rebate ──
          translate([0, 0, lid_step_h / 2])
            cube([lid_inner_l, lid_inner_w, lid_h], center=true);
        }

        // Step 3: Cut out the underside, leaving the lid's recessed interior.
        translate([0, 0, lid_step_h / 2 + base_wall])
          cube([lid_inner_l - base_wall, lid_inner_w - base_wall, lid_h], center=true);
      }

      // Step 4: Add bosses around the screw holes.
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * boss_x, y * boss_y, lid_step_h / 2])
          cylinder(h=boss_d, d=boss_d * 2, center=true, $fn=32);
      }
    }

    // Step 5: Cut screw holes through the lid and bosses.
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * boss_x, y * boss_y, lid_step_h / 2])
        cylinder(h=lid_h * 10, d=screw_d, center=true, $fn=32);
    }
  }
}

lid();
