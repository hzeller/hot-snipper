// -*- mode: scad; c-basic-offset: 2; indent-tabs-mode: nil; -*-

$fn=96;
e=0.02;
PI=3.1415926536;

hole_count=18;   // This determines the length
button_hole_distance=25.4 / 1.5;  // our band

band_separation=0.75;               // How far apart we have the bands
band_thick=19.7 + band_separation;  // Actual width + separation.

stack=2;
side_wall_clearance=6.95;
axle_dia=6.5;   // 1/4" rod + extra; we use that for all axles, main and idlers

bands_per_wheel=0.5;
cut_slot_deep=10;

axle_display=axle_dia - 0.5;
spoke_angle=60;

// Main wheel parameters
wheel_wall=1;
spoke_thick=1;

hole_angle=360/(bands_per_wheel*hole_count);
circ=bands_per_wheel * hole_count * button_hole_distance;
radius=circ / (2*PI);

infeed_idler_dia=20;
outfeed_offset=0.5;

// Blades engaging with the button-holes
blade_h=3.5;
blade_w=0.9;
blade_l=5;

mount_holes = [[-30, -radius-3], [19, -radius-3],
	       [38, radius-10], [-28, radius+5]];

echo("circumreference ", circ, "; radius=", radius, "; teeth=", bands_per_wheel*hole_count, "; inner-width: ", stack * band_thick + 2*side_wall_clearance);

module mount_place(dia) {
  translate([0, 0, -band_thick/2]) cylinder(r=dia/2 + 2, h=band_thick);
}

module mount_place_punch(dia) {
  translate([0, 0, -(band_thick+e)/2]) cylinder(r=dia/2, h=band_thick+2*e);
}

module hole_retainer() {
  color("yellow") hull() {
    cube([e, blade_l, blade_w], center=true);
    translate([1.5, 0, 0]) cube([e, blade_l, blade_w], center=true);
    translate([blade_h, 0, 0]) cube([e, blade_l-2, blade_w], center=true);
  }
}

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
    rotate([0, 0, a]) translate([radius-0.5, 0, 0]) hole_retainer();
  }
}

module stack(layers=3, with_axle=true) {
  d=band_thick;
  axle_extra=side_wall_clearance + 10;
  for (i = [0:1:layers-e]) {
    translate([0, 0, i*d]) wheel_assembly();
  }
  if (with_axle) {
    translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=layers*band_thick+2*axle_extra);
  }
}

module knife(layers=3, anim_stage=0) {
  movement=15;
  side=0;
  down=sin(anim_stage*180) * movement;
  d=band_thick;
  translate([-side-d/2, -0.5, radius+10-down]) color("red") cube([layers*d+(2*side), 1, 30]);
}

module anim(s=4) {
  t=$t;
  rotate([0, 0, 0]) {
    rotate([180 + ((t < 0.8) ? (t/0.8) * 720 : 0), 0, 0]) rotate([0, 90, 0]) stack(s);
    knife(s, anim_stage = (t > 0.8) ? (t-0.8)/0.2 : 0);
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

//stack(2);

module wheel_idler(is_first=false, is_last=false) {
  center_free=3;
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

module wheel_idler_stack(s=5, print_distance=-1, with_axle=false, gravity_holes=false) {
  d = band_thick;
  color("blue") for (i = [0:1:s+1-e]) {
    is_first=(i == 0);
    is_last = (i == s);
    if (print_distance < 0) {
      translate([0, 0, is_first ? 0 : (i-0.5)*d+1.5])
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

module infeed_tray(s=5, len=40, extra=0) {
  color("silver") for (i = [0:1:s-e]) {
    translate([i*band_thick, 0, 0]) {
      cube([band_thick, len, 1]);
      cube([band_separation/2, len, 4]);
      translate([band_thick-band_separation/2, 0, 0])
        cube([band_separation/2+e, len, 4]);
    }
  }
  slot_w=20;
  sw_r=4/2 + extra;
  sw=side_wall_clearance+4;
  translate([-sw, 0, 0]) hull() {
    translate([0, 10, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
    translate([0, 10+slot_w, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
  }
  translate([s*band_thick, 0, 0]) hull() {
    translate([0, 10, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
    translate([0, 10+slot_w, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
  }

  translate([-side_wall_clearance, 10/2, 0]) cube([side_wall_clearance, 30, 4]);
  translate([s*band_thick, 10/2, 0]) cube([side_wall_clearance, 30, 4]);
}

module infeed_idler(outer=15) {
  difference() {
    union() {
      cylinder(r=outer, h=band_thick-band_separation-1);
      cylinder(r=outer-5, h=band_thick);
    }
    translate([0, 0, -e]) cylinder(r=axle_dia/2, h=band_thick+2*e);
  }
}

module infeed_idler_stack(s=5, print_distance=-1, with_axle=false, gravity_holes=false, outer=infeed_idler_dia/2) {
  d = band_thick;
  color("blue") for (i = [0:1:s-e]) {
    if (print_distance < 0) {
      translate([0, 0, i*d]) infeed_idler(outer);
    } else {
      translate([i*print_distance, 0, 0]) infeed_idler(outer);
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

module support_enforder(s=5) {
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

module mechanics_assembly(wheel_stack=2, gravity_holes=false, extra=0) {
  rotate([0, 0, 0]) {
    rotate([0, 0, 0]) {
      translate([-band_thick/2, 30, -radius-5]) infeed_tray(s=wheel_stack, len=34, extra=extra);
      translate([-band_thick/2+(band_separation+1)/2, 50, -radius-5+infeed_idler_dia/2+1.1]) rotate([0, 90, 0]) infeed_idler_stack(s=wheel_stack, with_axle=true, gravity_holes=gravity_holes);
    }
  }

  // Idlers around the knife
  rotate([-20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) wheel_idler_stack(wheel_stack, with_axle=true, gravity_holes=gravity_holes);
  rotate([20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) wheel_idler_stack(wheel_stack, with_axle=true, gravity_holes=gravity_holes);

  // Feed idler
  rotate([-120, 0, 0]) translate([-band_thick/2, 0, radius+8+2]) rotate([0, 90, 0]) wheel_idler_stack(wheel_stack, with_axle=true);

  anim(wheel_stack);
  rotate([45, 0, 0]) rotate([0, 0, 180]) color("violet") outfeed_stack(wheel_stack, extra=extra);

  for (h = mount_holes) {
    translate([0, h[0], h[1]]) rotate([0, 90, 0])
      translate([0, 0, -band_thick/2-side_wall_clearance])
      stack_spacer();
  }
}

module panel_corner(r=6, thick=3) {
  rotate([0, 90, 0]) translate([0, 0, -thick/2]) cylinder(r=r, h=thick);
}

module nema17_mount() {
  d=31/2;
  translate([-d, -d, 0]) cylinder(r=3.2/2, h=50);
  translate([ d, -d, 0]) cylinder(r=3.2/2, h=50);
  translate([ d, d, 0]) cylinder(r=3.2/2, h=50);
  translate([-d, d, 0]) cylinder(r=3.2/2, h=50);
}

module mount_panel(s=2, thick=3) {
  mount_panel_corners = [[-39, -radius - 6],  // bottom, out-feed side
                         [-39, -7], [-30, +radius+5],      // up out-feed side.
                         [-5, +radius+50], [+5, +radius+50], // summit
                         [60, 0], [60, -radius - 6]];  // down, in-feed


  color("azure", 0.1) difference() {
    translate([-band_thick/2-1.5-side_wall_clearance, 0, 0]) hull() {
      for (c = mount_panel_corners) {
        translate([0, c[0], c[1]]) panel_corner(thick=thick);
      }
    }
    mechanics_assembly(s, gravity_holes=true, extra=0.15);
    rotate([0, -90, 0]) nema17_mount();

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

module stack_spacer(s=stack) {
  total_width = stack * band_thick + 2*side_wall_clearance;
  color("azure", 0.25) difference() {
    cylinder(r=axle_dia/2+1, h=total_width);
    translate([0, 0, -e]) cylinder(r=axle_dia/2, h=total_width+2*e);
  }
}


// Useful outputting modules
module print_stack_spacer() {
  stack_spacer();
  translate([15, 0, 0]) stack_spacer();
  translate([0, 15, 0]) stack_spacer();
  translate([15, 15, 0]) stack_spacer();
}

module print_wheel_idler(s=stack) {
  wheel_idler_stack(s=s, print_distance=25);
  translate([0, 25, 0]) wheel_idler_stack(s=s, print_distance=25);
  translate([0, 2*25, 0]) infeed_idler_stack(s=s, print_distance=25);
}

module mount_panel_2d() {
  projection(cut=true) {
    translate([0, 0, -side_wall_clearance-band_thick/2-1.5]) rotate([0, 90, 0]) mount_panel(1);
  }
}

mechanics_assembly(stack);
//mount_panel(thick=2);
translate([stack*band_thick + 2*side_wall_clearance+3, 0, 0]) mount_panel(thick=3);
