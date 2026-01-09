// s14_flatface_deepdish_5spoke.scad
// Flat-face 5-spoke + deep lip/dish (visual/prototype)
// S14: 5x114.3, 66.1 bore
// Units: mm

$fn = 240;
inch = 25.4;

// -------- FITMENT (S14) --------
pcd_mm         = 114.3;
lug_count      = 5;
center_bore_mm = 66.1;
lug_hole_d_mm  = 14.5;

// -------- WHEEL LOOK --------
wheel_diameter_in = 18;
wheel_width_in    = 9;

ET_offset_mm      = -10;   // more negative = more dish look

barrel_wall_mm     = 7;

// Deep lip (front)
front_lip_depth_mm = 50;   // increase for more lip
lip_step_mm        = 16;

// Flat face + spokes
face_thickness_mm  = 14;
face_diameter_mm   = 330;

spoke_count        = 5;
spoke_width_mm     = 60;
spoke_thk_mm       = 16;
spoke_root_r_mm    = 75;
spoke_tip_r_mm     = 205;

// Dish controls
face_front_gap_mm  = 10;
bridge_extra_mm    = 12;

// -------- DERIVED --------
wheel_diameter = wheel_diameter_in * inch;
wheel_width    = wheel_width_in * inch;
r_outer        = wheel_diameter / 2;
z_half         = wheel_width / 2;

pcd_r = pcd_mm / 2;

// +Z front/outside, -Z back/inside
mount_face_z = ET_offset_mm;

// Face sits near front lip (flat face look)
face_z = (z_half - front_lip_depth_mm) - face_thickness_mm/2 - face_front_gap_mm;

// -------- BUILD --------
wheel();

module wheel() {
  difference() {
    union() {
      barrel_with_lip();     // already hollow inside itself
      flat_face_disc();
      spokes();
      mount_pad_and_bridge();
    }

    // Center bore
    cylinder(h=wheel_width + 80, r=center_bore_mm/2, center=true);

    // Lug holes
    lug_holes();
  }
}

module barrel_with_lip() {
  // Barrel ring (hollowed here only)
  difference() {
    cylinder(h=wheel_width, r=r_outer, center=true);
    cylinder(h=wheel_width + 2, r=r_outer - barrel_wall_mm, center=true);
  }

  // Front lip ring (cosmetic)
  translate([0,0, z_half - front_lip_depth_mm/2])
    difference() {
      cylinder(h=front_lip_depth_mm, r=r_outer, center=true);
      cylinder(h=front_lip_depth_mm + 2, r=r_outer - lip_step_mm, center=true);
    }
}

module flat_face_disc() {
  translate([0,0, face_z])
    cylinder(h=face_thickness_mm, r=face_diameter_mm/2, center=true);
}

module spokes() {
  for (i=[0:spoke_count-1]) {
    rotate([0,0,360/spoke_count*i]) spoke();
  }
}

module spoke() {
  len  = spoke_tip_r_mm - spoke_root_r_mm;
  rmid = spoke_root_r_mm + len/2;

  translate([rmid, 0, face_z])
    hull() {
      translate([-len/2,0,0]) cylinder(h=spoke_thk_mm, r=spoke_width_mm/2, center=true);
      translate([ len/2,0,0]) cylinder(h=spoke_thk_mm, r=spoke_width_mm/2, center=true);
    }
}

module mount_pad_and_bridge() {
  pad_d   = 140;
  pad_thk = 12;

  // Mounting pad at ET position
  translate([0,0, mount_face_z])
    cylinder(h=pad_thk, r=pad_d/2, center=true);

  // Bridge connects face to pad (solid printable part)
  bridge_mid = (face_z + mount_face_z)/2;
  bridge_h   = abs(face_z - mount_face_z) + bridge_extra_mm;

  translate([0,0, bridge_mid])
    cylinder(h=bridge_h, r=(pad_d/2)+10, center=true);
}

module lug_holes() {
  hole_h = wheel_width + 120;

  for (i=[0:lug_count-1]) {
    rotate([0,0,360/lug_count*i])
      translate([pcd_r, 0, mount_face_z])
        cylinder(h=hole_h, r=lug_hole_d_mm/2, center=true);
  }
}
