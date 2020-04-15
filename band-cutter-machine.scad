// -*- mode: scad; c-basic-offset: 2; indent-tabs-mode: nil; -*-

$fn=96;
e=0.02;
PI=3.1415926536;

stack=2;

//button_hole_distance=25.4 / 1.5;  // theoretical..
button_hole_distance=564 / 34;      // measured ...
hole_count=18;   // This determines the length of the final band. Must be even.

band_separation=4.1;               // How far apart we have the bands
baseline_band=19.8;                // Elastic band width.
band_thick=baseline_band + band_separation;  // Actual width + separation.

side_wall_clearance=7;           // e.g. for nuts and bolts.
axle_dia=6.5;   // 1/4" rod + extra; we use that for all axles, main and idlers

bands_per_wheel=0.5;
cut_slot_deep=10;

axle_display=axle_dia;
spoke_angle=60;

// Main wheel parameters
wheel_wall=1;
spoke_thick=1;

hole_angle=360/(bands_per_wheel*hole_count);
circ=bands_per_wheel * hole_count * button_hole_distance;
radius=circ / (2*PI);

idler_dia=16;
idler_cutout=4;
infeed_idler_dia=25;

rotation_clearance=0.3;

infeed_tray_high=4;
outfeed_offset=0.5;

nema_cutout=false;   // should we have a central cut-out for the nema17?

// Blades engaging with the button-holes
blade_h=3.5;
blade_w=0.7;
blade_l=4;

// Places where we add spacers to rigidly hold together the two side-frames.
mount_holes = [[-30, -radius-3], [36, -radius+10],
	       [30, radius+5],   [-28, radius+5]];

echo("circumreference ", circ, "; radius=", radius, "; teeth=", bands_per_wheel*hole_count, "; inner-width: ", stack * band_thick + 2*side_wall_clearance);

module mount_place(dia) {
  translate([0, 0, -band_thick/2]) cylinder(r=dia/2 + 2, h=band_thick);
}

module mount_place_punch(dia) {
  translate([0, 0, -(band_thick+e)/2]) cylinder(r=dia/2, h=band_thick+2*e);
}

// A 'tooth' engaging with a butotn hole.
module button_hole_tooth() {
  color("yellow") hull() {
    cube([e, blade_l, blade_w], center=true);
    translate([1.5, 0, 0]) cube([e, blade_l, blade_w], center=true);
    translate([blade_h, 0, 0]) cube([e, blade_l-2, blade_w], center=true);
  }
}

// Widening to accomodate hot knife through wheel.
module spoke_cut_widening(from_edge=cut_slot_deep) {
  widening_r=2 + spoke_thick;
  hull() {
    translate([radius - from_edge, 0, -band_thick/2]) cylinder(r=widening_r, h=band_thick);
    translate([radius, 0, -band_thick/2]) cylinder(r=widening_r, h=band_thick);
  }
}

module spoke_cut_widening_punch(from_edge=cut_slot_deep) {
  translate([radius-from_edge, 0, -15]) hull() {
    cylinder(r=2, h=30);
    translate([50, 0, 0]) cylinder(r=2, h=30);
  }
}

module basic_wheel() {
  translate([0, 0, -band_thick/2]) difference() {
    cylinder(r=radius, h=band_thick);
    translate([0, 0, -e]) cylinder(r=radius-wheel_wall, h=band_thick+2*e);
  }

  intersection() {
    translate([0, 0, -band_thick/2]) difference() {
      cylinder(r=radius, h=band_thick);
      translate([0, 0, -e]) cylinder(r=radius-wheel_wall, h=band_thick+2*e);
    }
    union() {
      support_arc(0, 30, radius=radius+10, high=band_thick);
      if (bands_per_wheel==2)
        support_arc(180, 30, radius=radius+10, high=band_thick);
    }
  }

  // spokes.
  intersection() {
    union() {
      for (a=[0:spoke_angle:360]) {
        rotate([0, 0, a]) {
          translate([radius/2, 0, 0]) cube([radius, spoke_thick, band_thick], center=true);
        }
      }
      spoke_cut_widening();
    }

    translate([0, 0, -band_thick/2]) cylinder(r=radius, h=band_thick);
  }

  mount_place(dia=axle_dia);  // axle in center
}

module wheel_assembly() {
  difference() {
    basic_wheel();
    spoke_cut_widening_punch();
    mount_place_punch(dia=axle_dia);
  }

  for (a=[hole_angle/2:hole_angle:360-e]) {
    rotate([0, 0, a]) translate([radius-0.5, 0, 0]) button_hole_tooth();
  }
}

module wheel_stack(layers=stack, with_axle=false) {
  d=band_thick;
  axle_extra=side_wall_clearance + 10;
  for (i = [0:1:layers-e]) {
    translate([0, 0, i*d]) wheel_assembly();
  }
  if (with_axle) {
    translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=layers*band_thick+2*axle_extra);
  }
}

module knife(s=stack) {
  side=0;
  d=band_thick;
  translate([-side-d/2, -0.5, radius+10]) color("red") cube([s*d, 1, 30]);
}

module anim(s=4) {
  t=$t;
  rotate([0, 0, 0]) {
    rotate([180 + ((t < 0.8) ? (t/0.8) * 720 : 0), 0, 0]) rotate([0, 90, 0]) wheel_stack(s, with_axle=true);
    knife_anim_stage=(t > 0.8) ? (t-0.8)/0.2 : 0;
    movement=15;
    down=sin(knife_anim_stage*180) * movement;
    translate([0, 0, -down]) knife(s);
  }
}

module arc_range(start=-10, end=10, radius=100, high=5) {
  hull() {
    cylinder(r=e, h=high);
    rotate([0, 0, start]) translate([radius, 0, 0]) cylinder(r=e, h=high);
    rotate([0, 0, end]) translate([radius, 0, 0]) cylinder(r=e, h=high);
  }
}

module support_arc(center=0, angle_dist=10, radius=100, high=10) {
  small_dist=angle_dist/3;
  hull() {
    translate([0, 0, high/2]) arc_range(start=center-small_dist, end=center+small_dist, radius=radius, high=e);
    arc_range(start=center-angle_dist, end=center+angle_dist, radius=radius, high=e);
    translate([0, 0, -high/2]) arc_range(start=center-small_dist, end=center+small_dist, radius=radius, high=e);
  }
}

module wheel_idler(is_first=false, is_last=false) {
  center_free=idler_cutout;
  outer=8;
  big_part=(is_first || is_last)
    ? (band_thick-center_free)/2
    : (band_thick-center_free);
  difference() {
    union() {
      cylinder(r=outer, h=big_part);
      if (!is_last) cylinder(r=outer-3, h=big_part+center_free);
    }
    translate([0, 0, -e]) cylinder(r=axle_dia/2, h=band_thick+2*e);
  }
}

module wheel_idler_stack(s=stack, print_distance=-1, with_axle=false, gravity_holes=false) {
  d = band_thick;
  color("blue") for (i = [0:1:s+1-e]) {
    is_first=(i == 0);
    is_last = (i == s);
    if (print_distance < 0) {
      translate([0, 0, is_first ? 0 : (i-0.5)*d+idler_cutout/2])
        wheel_idler(is_first=is_first, is_last=is_last);
    } else {
      translate([i*print_distance, 0, 0])
        wheel_idler(is_first=is_first, is_last=is_last);
    }
  }

  axle_extra=side_wall_clearance + 10;
  if (with_axle) {
    color("gray") translate([0, 0, -axle_extra]) cylinder(r=axle_display/2, h=s*d+2*axle_extra);
  }

  if (gravity_holes) {
    hull() {
      translate([1, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
      translate([-15, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
    }
  }
}

module infeed_idler(outer=15, is_last=false) {
  difference() {
    union() {
      cylinder(r=outer, h=band_thick-band_separation-1);
      if (!is_last) cylinder(r=axle_dia/2+1, h=band_thick);
    }
    translate([0, 0, -e]) cylinder(r=axle_dia/2, h=band_thick+2*e);
  }
}

module infeed_idler_stack(s=5, print_distance=-1, with_axle=false, gravity_holes=false, outer=infeed_idler_dia/2) {
  d = band_thick;
  color("blue") for (i = [0:1:s-e]) {
    is_last= (i == s-1);
    if (print_distance < 0) {
      translate([0, 0, i*d]) infeed_idler(outer, is_last=is_last);
    } else {
      translate([i*print_distance, 0, 0]) infeed_idler(outer, is_last=is_last);
    }
  }
  axle_extra=side_wall_clearance + 10;
  if (with_axle) {
    translate([0, 0, -axle_extra])
      color("gray") cylinder(r=axle_display/2, h=s*d + 2*axle_extra);
  }
  if (gravity_holes) {
    hull() {
      translate([1, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
      translate([-15, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
    }
  }
}

module support_enforder(s=stack) {
  translate([0, 0, -band_thick/2]) difference() {
    cylinder(r=radius+3.5, h=s*band_thick);
    translate([0, 0, -e]) cylinder(r=radius+2.5, h=s*band_thick+2*e);
  }
}

module outfeed_material() {
  translate([-band_thick/2, outfeed_offset, radius+outfeed_offset]) {
    translate([0, 2, -4]) cube([band_thick, 15, 4]);
  }
}

module outfeed_punch() {
  rotate([0, 90, 0]) translate([0, 0, -band_thick/2-e]) cylinder(r=radius+outfeed_offset, h=band_thick+2*e);
  rotate([0, 90, 0]) translate([0, 0, -2-e]) cylinder(r=radius+outfeed_offset+blade_h+2, h=4+2*e);
}

module outfeed_stack_material(s=3, extra=0) {
  d = band_thick;
  for (i = [0:1:s-e]) {
    translate([-d*i, 0, 0]) outfeed_material();
  }

  slot_w=13;
  sw_r=4/2+extra;
  sw=side_wall_clearance+4;

  // Rounded slot mount
  translate([-d*s+d/2-sw, 0, 0]) hull() {
    translate([0, 19, radius-4/2+outfeed_offset]) rotate([0, 90, 0]) cylinder(r=sw_r, h=2*sw+d*s);
    translate([0, 19+slot_w, radius-4/2+outfeed_offset]) rotate([0, 90, 0]) cylinder(r=sw_r, h=2*sw+d*s);
  }

  // bar, also shoulder.
  translate([-d*s/2+d/2, 19+slot_w/2, radius-4/2+outfeed_offset]) cube([2*side_wall_clearance+d*s, slot_w+6, 4], center=true);
}

module outfeed_stack_punch(s=3, extra=0) {
  d = band_thick;
  for (i = [0:1:s-e]) {
    translate([-d*i, 0, 0]) outfeed_punch();
  }
}

module outfeed_stack(s=3, extra=0) {
  difference() {
    outfeed_stack_material(s, extra);
    outfeed_stack_punch(s, extra);
  }
}

module infeed_tray(s=5, len=40, extra=0) {
  color("silver") for (i = [0:1:s-e]) {
    translate([i*band_thick, 0, 0]) {
      difference() {
        cube([band_thick, len, 1]);
        // since it is centered, we end up cutting out len/4
        translate([band_thick/2, 0, 0]) cube([4, len/2, 3], center=true);
      }
      cube([band_separation/2, len, infeed_tray_high]);
      translate([band_thick-band_separation/2, 0, 0])
        cube([band_separation/2+e, len, infeed_tray_high]);
    }
  }
}

module infeed_hinge_material(hinge_thick, clearance, tray_idler_distance, tray_idler_shift) {
  idler_r = idler_dia/2;
  snap_high=8;  // we connect to the tray the same way as the snap connect
  // Hinge
  hull() {
    translate([-(hinge_thick+clearance), 0, 0]) rotate([0, 90, 0]) cylinder(r=idler_r, h=hinge_thick);
    translate([-(clearance+hinge_thick), tray_idler_shift, -idler_r-infeed_tray_high-tray_idler_distance]) cube([hinge_thick, idler_r, infeed_tray_high]);
  }
  // Hinge connect
  translate([-(clearance+hinge_thick), tray_idler_shift, -idler_r-infeed_tray_high-tray_idler_distance]) cube([clearance+hinge_thick+e, idler_r, snap_high]);
}

module infeed_hinge_punch(hinge_thick, clearance) {
  translate([-(hinge_thick+clearance)-e, 0, 0]) rotate([0, 90, 0]) cylinder(r=axle_dia/2, h=hinge_thick+2*e);
}

module infeed_hinge(hinge_thick, clearance, tray_idler_distance,
                    tray_idler_shift) {
  difference() {
    infeed_hinge_material(hinge_thick, clearance, tray_idler_distance, tray_idler_shift);
    infeed_hinge_punch(hinge_thick, clearance);
  }
}

module snap_lock(w=side_wall_clearance, l=10, h=infeed_tray_high,
                 snap_detent=2, do_punch=false) {
  lock_r=4/2;
  hinge_thick=1;
  spring_travel=snap_detent*2;
  finger_extra_len=8;
  bend_len=15;  // TODO: calculate from some material modulus
  difference() {
    union() {
      translate([-w, 0, 0]) cube([w, l, h]);  // body
      translate([-w, 0, 0]) {
        cube([spring_travel/2, l+finger_extra_len, h]);  // finger extension
        grab_len=3.5;  // Fudged, matches back side panel.

        // Make a little rough thing to grab on to.
        translate([0, l+finger_extra_len-grab_len, 0]) {
          //cube([2, grab_len, h]);
          r=grab_len/4;
          translate([0, grab_len-r, 0]) cylinder(r=r, h=h);
          translate([0, +r, 0]) cylinder(r=r, h=h);
        }
      }

      // Snap poky thing
      translate([0, l-lock_r, h/2]) rotate([0, -90, 0])
        cylinder(r=lock_r + (do_punch ? 0.3 : 0), h=w+snap_detent + (do_punch ? 10 : 0));
    }
    hull() {
      translate([-w/2, l-bend_len, -e]) cylinder(r=w/2-hinge_thick, h=h+2*e);
      translate([-w+spring_travel/2+hinge_thick, l, -e]) cylinder(r=spring_travel/2, h=h+2*e);
    }
  }
}

module infeed_fancy_tray(wheel_stack=stack, extra=0) {
  idler_r=idler_dia/2;
  tray_idler_distance=1;
  tray_idler_shift=5;
  tray_len=34;
  below=idler_r + infeed_tray_high + tray_idler_distance;

  translate([0, tray_idler_shift, -below])
    infeed_tray(s=wheel_stack, len=tray_len, extra=extra);

  // Snap lock
  translate([0, tray_idler_shift+7, -below])
    snap_lock(h=8, l=tray_len-7, do_punch = (extra > 0));
  translate([wheel_stack*band_thick, tray_idler_shift+7, -below])
    scale([-1, 1, 1]) snap_lock(h=8, l=tray_len-7, do_punch = (extra > 0));

  // hinge
  infeed_hinge(side_wall_clearance-2*rotation_clearance, rotation_clearance, tray_idler_distance, tray_idler_shift);
  // same, mirrored on other side.
  translate([wheel_stack*band_thick, 0, 0]) scale([-1, 1, 1])
    infeed_hinge(side_wall_clearance-2*rotation_clearance, rotation_clearance, tray_idler_distance, tray_idler_shift);
}

module infeed_assembly(wheel_stack=2, correct_angle=0, extra=0, gravity_holes=false) {
  idler_r=idler_dia/2;
  translate([-band_thick/2, 0, 0]) rotate([correct_angle, 0, 0]) {
    rotate([0, 90, 0]) wheel_idler_stack(wheel_stack, with_axle=true);
    infeed_fancy_tray(wheel_stack, extra=extra);
  }

  // this    v-- is fudging it. Somewhere else this offset is broken
  translate([-band_thick/2+0.5+band_separation/2,
             30,
             0.5])
    rotate([0, 90, 0]) infeed_idler_stack(s=wheel_stack, with_axle=true, gravity_holes=gravity_holes);
}

// All the mechanics combined: wheel and idlers.
module mechanics_assembly(wheel_stack=2, gravity_holes=false, extra=0) {
  ia=-42;     // infeed angle
  id=radius+idler_dia/2+2; // infeed distance
  translate([0, cos(ia)*id, sin(ia)*id])
    infeed_assembly(wheel_stack, 0, extra, gravity_holes=gravity_holes);

  // Idlers around the knife
  rotate([-20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) wheel_idler_stack(wheel_stack, with_axle=true, gravity_holes=gravity_holes);
  rotate([20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) wheel_idler_stack(wheel_stack, with_axle=true, gravity_holes=gravity_holes);

  // Outfeed
  rotate([45, 0, 0]) rotate([0, 0, 180]) color("violet") outfeed_stack(wheel_stack, extra=extra);

  // Wheel + knife. Animatable.
  anim(wheel_stack);

  // Spacers to mount assembly together.
  for (h = mount_holes) {
    translate([0, h[0], h[1]]) rotate([0, 90, 0])
      translate([0, 0, -band_thick/2-side_wall_clearance])
      stack_spacer();
  }
}

module panel_corner(r=6, thick=3) {
  rotate([0, 90, 0]) translate([0, 0, -thick/2]) cylinder(r=r, h=thick);
}

module nema17_punch(h=50) {
  d=31/2;
  for (p = [[-d, -d], [d, -d], [d, d], [-d, d]]) {
    translate(p) cylinder(r=3.2/2, h=h);
  }
  if (nema_cutout) cylinder(r=22.5/2, h=h);
}

module mount_panel(thick=2, with_motor=true) {
  s=1;
  mount_panel_corners = [[-39, -radius - 6],  // bottom, out-feed side
                         [-39, -7], [-30, +radius+5],      // up out-feed side.
                         [-5, +radius+50], [+5, +radius+50], // summit
                         [62, 0], [62, -radius - 6]];  // down, in-feed


  color("azure", 0.1) difference() {
    translate([-band_thick/2-1.5-side_wall_clearance, 0, 0]) hull() {
      for (c = mount_panel_corners) {
        translate([0, c[0], c[1]]) panel_corner(thick=thick);
      }
    }
    mechanics_assembly(s, gravity_holes=true, extra=0.15);
    if (with_motor) rotate([0, -90, 0]) nema17_punch();

    // Knife slide
    translate([-band_thick/2-1.5-side_wall_clearance, 0, 0]) {
      above=18;
      hull() {
        translate([0, 0, radius + above]) panel_corner(r=4/2, thick=4);
        translate([0, 0, radius + above+20]) panel_corner(r=4/2, thick=4);
      }
      translate([0, 0, radius + above+30]) panel_corner(r=3.2/2, thick=4);
    }

    axle_extra=side_wall_clearance + 10;
    for (h = mount_holes) {
      translate([0, h[0], h[1]]) rotate([0, 90, 0])
        translate([0, 0, -band_thick/2-axle_extra])
        cylinder(r=axle_dia/2, h=s*band_thick+2*axle_extra);
    }
  }
}

module hollow_cylinder(r=10, axle_r=8, h=10) {
  difference() {
    cylinder(r=r, h=h);
    translate([0, 0, -e]) cylinder(r=axle_r, h=h+2*e);
  }
}

module stack_spacer(s=stack) {
  total_width = stack * band_thick + 2*side_wall_clearance;
  color("azure", 0.25) hollow_cylinder(r=axle_dia/2+1, axle_r=axle_dia/2,
                                       h=total_width);
}


// Useful outputting modules
module print_stack_spacer() {
  stack_spacer();
  translate([15, 0, 0]) stack_spacer();
  translate([0, 15, 0]) stack_spacer();
  translate([15, 15, 0]) stack_spacer();
}

module print_wheel_idler(s=stack) {
  // We need three: two on top, one at the infeed.
  pack_offset_x=cos(60) * (idler_dia/2) * 2;
  pack_offset_y=sin(60) * (idler_dia/2+0.3) * 2;
  for (i = [0:1:3-e]) {
    translate([i%2==1 ? pack_offset_x : 0, i*pack_offset_y, 0])
      wheel_idler_stack(s=s, print_distance=idler_dia+0.3);
  }
}

module print_infeed_weight_idler(s=stack) {
  infeed_idler_stack(s=s, print_distance=infeed_idler_dia+1);
}

module mount_panel_2d() {
  projection(cut=true) {
    translate([0, 0, -side_wall_clearance-band_thick/2-1.5]) rotate([0, 90, 0]) mount_panel();
  }
}

module print_outfeed() {
  rotate([0, 180, 0]) outfeed_stack(stack);
}

// Distance rings. TODO: at some point, include that in the design, for
// now we just add them as separate things to use.
module print_sidewall_clearance_distance_rings() {
  outer=axle_dia+4;
  place_dist=outer+0.1;
  pack_offset_x=cos(60) * place_dist;
  pack_offset_y=sin(60) * place_dist;
  for (row = [0:1:2-e]) {
    for (col = [0:1:4-e]) {
      // We need two for the outer rollers
      height = side_wall_clearance + ((col == 0) ? band_separation/2 : 0)
        - rotation_clearance;  // These are always used on rotating parts.
      translate([row*place_dist + ((col % 2 == 0) ? pack_offset_x : 0),
                 col*pack_offset_y, 0])
        hollow_cylinder(r=outer/2, axle_r=axle_dia/2, h=height);
    }
  }
}

module full_assembly() {
  panel_thickness=3;
  mechanics_assembly(stack);
  mount_panel(thick=panel_thickness);
  // The other side has the motor mount.
  translate([stack*band_thick + 2*side_wall_clearance+3, 0, 0]) mount_panel(thick=panel_thickness, with_motor=true);

  translate([stack*band_thick - band_thick/2 + side_wall_clearance+panel_thickness, 0, 0]) nema_motor_stand();
}

module pcb_rails(outer_w=40, inner_w=30, len=30) {
  pcb_thick=1.8;
  rail_thick=1;
  translate([len/2, 0, 0]) difference() {
    union() {
      translate([0, 0, +(pcb_thick+rail_thick)/2]) cube([len, outer_w, rail_thick], center=true);
      translate([0, 0, -(pcb_thick+rail_thick)/2]) cube([len, outer_w, rail_thick], center=true);
    }

    cube([len+2*e, inner_w, pcb_thick+2*rail_thick+2*e], center=true);
  }
}

module print_nema_motor_stand() {
  // TODO: derived from lowest point in mount_panel_corners and corner radius.
  below_center=radius + 6 + 6;
  motor_deep=49;
  flange_thick=2.1;
  d=31/2;      // Distance of nema holes.
  corner_r=5;
  motor_body_size=42.2;   // Nominal 1.7"
  center_hole=22.2;
  cable_w=9;
  cable_from_front=38 + flange_thick;
  cable_deep=15;  // just long enough to punch out at the back;
  difference() {
    union() {
      hull() {
        for (p = [[-d,-d], [-d, d], [d+5, -d], [d+5, d]])
          translate(p) cylinder(r=5, h=flange_thick);
      }
      w=2*(d+corner_r);
      translate([motor_body_size/2, -w/2, 0])
        cube([below_center - motor_body_size/2, w, motor_deep]);
    }

    translate([0, 0, -e]) {
      cylinder(r=center_hole/2, flange_thick+2*e);
      nema17_punch();
      // Cable cutout.
      translate([0, -cable_w/2, cable_from_front])
        cube([below_center, cable_w, cable_deep+e]);
      // neat 'dome' cutout.
      translate([42+2, 0, 0]) cylinder(r=42/2, h=motor_deep+2*e);
    }
  }
  translate([below_center-8, 0, 0]) rotate([0, -90, 0])
    pcb_rails(len=motor_deep-10, outer_w=40, inner_w=15);
}

module nema_motor_stand() {
  rotate([0, 90, 0]) print_nema_motor_stand();
}

full_assembly();
