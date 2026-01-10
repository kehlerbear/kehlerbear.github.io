/*
  rim_barrel.scad
  Pocket-free + center/web restored:

  - Outer is a solid revolve (closed to axis)
  - Inner is ALSO a solid revolve (closed to axis) with a smooth cavity + lip ramps
  - difference() gives ONE continuous cavity (no trapped pockets)
  - Visible exterior waist on the OUTSIDE drum
  - Flange/lip present

  Units: mm
*/

$fn = 240;
function in2mm(x) = x * 25.4;

module rim_barrel(
  diameter_in = 18,
  width_in    = 9.5,

  wall = 6,

  // Lip / flange
  flange_height   = 19,
  flange_thick=12,
  lip_radius      = 3,
  flange_overhang = 10,

  // Lip support ramp length (controls how quickly flange ties into drum)
  lip_support_len = 26,

  // Visible exterior waist on outer drum
  outer_drop_enable = true,
  outer_drop_depth  = 12,
  outer_drop_len    = 85,
  outer_drop_blend  = 14,

  // Center barrel band (adds a middle section)
  barrel_mid_enable = true,
  barrel_mid_raise  = 6,
  barrel_mid_len    = 50,
  barrel_mid_blend  = 12,

  // Edge flange on barrel ends
  edge_flange_enable = true,
  edge_flange_height=24,
  edge_flange_len=12,

  // Small round-off on inner flange corners
  inner_edge_fillet  = 2,

  // Inner cavity shaping (restores “center/web” look while keeping one open cavity)
  inner_ramp_len    = 30,  // how far the cavity ramps near each lip (bigger = more material)
  inner_center_bulge = 0,  // optional: >0 makes cavity slightly larger in the middle (usually leave 0)

  // Inner mounting ledge for a plate
  inner_mount_enable = true,
  inner_mount_side   = "left",   // "left" or "right"
  inner_mount_depth  = 30, // radial step inward from base cavity
  inner_mount_len    = 50.8,     // axial length of ledge
  inner_mount_offset_frac = 0.25, // fraction of drum length from the end

  // Bolt holes on the mounting ledge
  inner_mount_hole_enable = true,
  inner_mount_hole_count  = 36,
  inner_mount_hole_dia    = 13,
  inner_mount_hole_depth  = 15,

  // Close-to-axis safety
  axis_r = 0.2,

  // boolean stability
  eps = 0.05
){
  BSD    = in2mm(diameter_in);
  R_bead = BSD/2;

  W       = in2mm(width_in);
  W_total = W + 2*flange_overhang;

  // rotate_extrude uses 2D y as Z in 3D
  z0 = -W_total/2;
  z1 = z0 + flange_overhang;
  z8 = (W_total/2) - flange_overhang;
  z9 =  W_total/2;

  // Outer radii
  R_outer_drum = R_bead + flange_thick;
  R_flange_top = R_bead + flange_height;

  // Waist band (centered)
  z4 = -outer_drop_len/2;
  z5 =  outer_drop_len/2;

  R_outer_drop = outer_drop_enable ? (R_outer_drum - outer_drop_depth) : R_outer_drum;

  // Center barrel band (centered)
  zM0 = -barrel_mid_len/2;
  zM1 =  barrel_mid_len/2;
  R_outer_mid = R_outer_drum + barrel_mid_raise;

  // Edge flange (ends)
  edge_flange_len_eff = max(0, min(edge_flange_len, flange_overhang - lip_radius - eps));
  edge_flange_on = edge_flange_enable && (edge_flange_len_eff > 0);
  zE0 = z0 + edge_flange_len_eff;
  zE1 = z9 - edge_flange_len_eff;
  R_outer_edge = R_outer_drum + edge_flange_height;

  // Clamp fillets to safe sizes
  f_edge = min(inner_edge_fillet, edge_flange_len_eff, edge_flange_height);
  f_flange = min(inner_edge_fillet, lip_radius, (R_flange_top - R_outer_drum));

  // Helpers
  function xr(x) = max(axis_r, x);

  // Guards
  if (wall <= 0) echo("WARNING: wall must be > 0.");
  if (R_outer_drum - wall <= axis_r + 0.5) echo("WARNING: wall too thick; inner radius collapses.");

  // Lip-support ramp endpoints (outer)
  z_support_L = z1 + lip_radius + lip_support_len;
  z_support_R = z8 - lip_radius - lip_support_len;

  // -------------------------
  // OUTER boundary (x=radius, y=z)
  // -------------------------
  outer_boundary = [
    // Left edge -> lip
    [xr(R_outer_drum), z0],
    edge_flange_on ? [xr(R_outer_edge), z0] : [xr(R_outer_drum), z0],
    edge_flange_on ? [xr(R_outer_edge), zE0 - f_edge] : [xr(R_outer_drum), z0],
    edge_flange_on ? [xr(R_outer_edge - f_edge), zE0] : [xr(R_outer_drum), z1 - lip_radius],
    edge_flange_on ? [xr(R_outer_drum), zE0] : [xr(R_outer_drum), z1 - lip_radius],
    [xr(R_outer_drum), z1 - lip_radius],

    [xr(R_outer_drum), z1 - f_flange],
    [xr(R_outer_drum + f_flange), z1],
    [xr(R_flange_top), z1],
    [xr(R_flange_top), z1 + lip_radius],

    // Ramp down to drum (connects flange to center)
    [xr(R_outer_drum), z_support_L],

    // Drum -> center section (barrel band or waist)
    barrel_mid_enable ?
      [xr(R_outer_drum), zM0 - barrel_mid_blend] : [xr(R_outer_drum), z4 - outer_drop_blend],
    barrel_mid_enable ?
      [xr(R_outer_mid), zM0] : [xr(R_outer_drop), z4],
    barrel_mid_enable ?
      [xr(R_outer_mid), zM1] : [xr(R_outer_drop), z5],
    barrel_mid_enable ?
      [xr(R_outer_drum), zM1 + barrel_mid_blend] : [xr(R_outer_drum), z5 + outer_drop_blend],

    // Drum -> right ramp -> right lip -> edge
    [xr(R_outer_drum), z_support_R],

    [xr(R_flange_top), z8 - lip_radius],
    [xr(R_flange_top), z8],
    [xr(R_outer_drum + f_flange), z8],
    [xr(R_outer_drum), z8 + f_flange],

    edge_flange_on ? [xr(R_outer_drum), zE1] : [xr(R_outer_drum), z9],
    edge_flange_on ? [xr(R_outer_edge - f_edge), zE1] : [xr(R_outer_drum), z9],
    edge_flange_on ? [xr(R_outer_edge), zE1 + f_edge] : [xr(R_outer_drum), z9],
    edge_flange_on ? [xr(R_outer_edge), z9] : [xr(R_outer_drum), z9],
    [xr(R_outer_drum), z9]
  ];

  // Close outer polygon to axis (makes a solid wedge to revolve)
  outer_solid_pts = concat(outer_boundary, [[axis_r, z9], [axis_r, z0]]);

  // -------------------------
  // INNER cavity boundary (smooth + ramps so “center/web” remains)
  // - No exterior waist on the cavity (keeps it simple)
  // - Ramps near lips to avoid “missing center” look
  // -------------------------
  R_inner_base = R_outer_drum - wall; // base cavity radius

  // Where cavity ramps start/end near each side
  ziL0 = z1 + lip_radius + eps;
  ziL1 = ziL0 + inner_ramp_len;

  ziR1 = z8 - lip_radius - eps;
  ziR0 = ziR1 - inner_ramp_len;

  // Optional slight cavity change at the middle (usually keep 0)
  R_inner_mid = xr(R_inner_base + inner_center_bulge);
  inner_mount_left = (inner_mount_side == "left");
  inner_mount_right = (inner_mount_side == "right");
  inner_mount_offset = W_total * inner_mount_offset_frac;

  R_inner_mount = xr(R_inner_base - inner_mount_depth);
  zML0 = z0 + inner_mount_offset;
  zML1 = zML0 + inner_mount_len;
  zMR1 = z9 - inner_mount_offset;
  zMR0 = zMR1 - inner_mount_len;

  R_hole = xr(R_inner_base - (inner_mount_depth/2));
  z_hole_start = inner_mount_left ? zML0 : zMR1;
  z_hole_base  = inner_mount_left ? z_hole_start : (z_hole_start - inner_mount_hole_depth);

  inner_boundary = concat(
    [
      // Left cavity starts a bit inside the barrel
      [xr(R_inner_base), z0 - eps],
      [xr(R_inner_base), ziL0]
    ],
    inner_mount_enable && inner_mount_left ? [
      // Left mounting ledge
      [xr(R_inner_base), zML0],
      [xr(R_inner_mount), zML0],
      [xr(R_inner_mount), zML1],
      [xr(R_inner_base), zML1]
    ] : [],
    [
      // Ramp to mid radius (this is what connects the center feel)
      [xr(R_inner_mid),  ziL1],

      // Straight through center
      [xr(R_inner_mid),  ziR0]
    ],
    inner_mount_enable && inner_mount_right ? [
      // Right mounting ledge
      [xr(R_inner_base), zMR0],
      [xr(R_inner_mount), zMR0],
      [xr(R_inner_mount), zMR1],
      [xr(R_inner_base), zMR1]
    ] : [],
    [
      // Ramp back to base near right lip
      [xr(R_inner_base), ziR1],
      [xr(R_inner_base), z9 + eps]
    ]
  );

  // Close inner polygon to axis (this makes a solid to subtract)
  inner_solid_pts = concat(inner_boundary, [[axis_r, z9 + eps], [axis_r, z0 - eps]]);

  difference() {
    // Outer solid
    rotate_extrude(angle=360)
      polygon(points = outer_solid_pts);

    // Inner cavity solid (single continuous cavity; no trapped pockets)
    rotate_extrude(angle=360)
      polygon(points = inner_solid_pts);

    // Bolt holes in the mounting ledge
    if (inner_mount_enable && inner_mount_hole_enable) {
      for (i = [0 : inner_mount_hole_count - 1]) {
        rotate([0, 0, i * 360 / inner_mount_hole_count])
          translate([R_hole, 0, z_hole_base])
            cylinder(h = inner_mount_hole_depth, d = inner_mount_hole_dia);
      }
    }
  }
}

// Default
rim_barrel(
  diameter_in=18,
  width_in=9.5,

  wall=6,
  flange_height=19,
  flange_thick=12,
  flange_overhang=10,
  lip_support_len=26,

  outer_drop_enable=true,
  outer_drop_depth=12,
  outer_drop_len=85,
  outer_drop_blend=14,

  barrel_mid_enable=true,
  barrel_mid_raise=6,
  barrel_mid_len=50,
  barrel_mid_blend=12,

  edge_flange_enable=true,
  edge_flange_height=24,
  edge_flange_len=12,

  inner_ramp_len=30,
  inner_center_bulge=0
);






