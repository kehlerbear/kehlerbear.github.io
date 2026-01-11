// rim_assembly.scad
// Combined drum + plate assembly with aligned bolt circles

use <rim_barrel2.scad>;
use <rimplate.scad>;

// Drum parameters (match rim_barrel2 defaults)
diameter_in = 18;
width_in = 9.5;
flange_overhang = 10;
inner_mount_side = "left";
inner_mount_offset_mm = 60;
inner_mount_len = 50.8;
inner_mount_hole_depth = inner_mount_len;

// Plate thickness for axial placement (mm)
plate_thickness = 25.4;
center_pad_extra_thickness = 18;
plate_total_thickness = plate_thickness + center_pad_extra_thickness;

function in2mm(x) = x * 25.4;
W = in2mm(width_in);
W_total = W + 2 * flange_overhang;
z0 = -W_total / 2;
z9 =  W_total / 2;

// Place plate so it rests on the inside face of the ledge
z_plate = (inner_mount_side == "left")
  ? (z0 + inner_mount_offset_mm + inner_mount_len - plate_total_thickness)
  : (z9 - inner_mount_offset_mm - inner_mount_len - plate_total_thickness);

// Assemble (holes align by shared origin and matching BCD)
rotate([180,0,0])
rotate([0,0,180]) {
  rim_barrel(
    diameter_in = diameter_in,
    width_in = width_in,
    flange_overhang = flange_overhang,
    inner_mount_side = inner_mount_side,
    inner_mount_offset_mm = inner_mount_offset_mm,
    inner_mount_len = inner_mount_len,
    inner_mount_hole_depth = inner_mount_hole_depth
  );
  translate([0,0,z_plate])
    rim_plate();
}
