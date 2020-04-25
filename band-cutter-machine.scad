// -*- mode: scad; c-basic-offset: 2; indent-tabs-mode: nil; -*-
// (c) 2020 Henner Zeller <h.zeller@acm.org>
//
// This file is provided under the license condition of Creative Commons BY-SA
// https://creativecommons.org/licenses/by-sa/4.0/

use <utils.scad>

$fn=96;
e=0.01;
PI=3.1415926536;

stack=2;

// In one animation, we go through a few cycles, as we move camera positions.
anim_t=5*$t % 1;

//button_hole_distance=25.4 / 1.5;  // theoretical..
button_hole_distance=564 / 34;      // measured ...
hole_count=18;   // This determines the length of the final band. Must be even.

band_separation=4.1;               // How far apart we have the bands
baseline_band=19.8;                // Elastic band width.
band_thick=baseline_band + band_separation;  // Actual width + separation.

side_wall_clearance=16;           // Clearance mostly for the hot wire.
axle_dia=6.5;   // 1/4" rod + extra; we use that for all axles, main and idlers
axle_hex_flat_size=11;  // hex nut for above.
axle_hex_thick=6;

bands_per_wheel=0.5;
cut_slot_deep=10;

axle_display=axle_dia;
spoke_angle=60;

// Main wheel parameters
wheel_wall=1;
spoke_thick=1;
spoke_slot=4;

hole_angle=360/(bands_per_wheel*hole_count);
circ=bands_per_wheel * hole_count * button_hole_distance;
radius=circ / (2*PI);

idler_dia=16;
idler_cutout=4;
infeed_idler_dia=25;

knife_movement=25;     // Total vertical movement

stack_spacer_wall=1.5;   // od vs. id for stack spacer tubes.
stack_spacer_rod_dia=axle_dia;

// the part engaging with the frame. This is multiple of 3mm as cut from
// plywood.
knife_slide_layers=7;
knife_slide_top_layers=3;
knife_slide_layer_thick=3;
knife_slide_len=knife_slide_layers * knife_slide_layer_thick;
knife_slide_top_len=knife_slide_top_layers * knife_slide_layer_thick;
knife_slide_rod_hole=4.3;   // The diameter threaded rod holding the wire.

knife_slider_above_wire=30;
knife_into_wheel=4;   // How deep we go into the slot. Mostly for animation
knife_slider_slot_w=20;
knife_slider_ring_support=5;       // Ring that wraps around slide dagger
knife_slider_bottom_block_w=15;    // Needs to support at least the nut diameter

fit_tolerance=0.3;                 // Tolerance of parts in contact.
slide_tolerance=fit_tolerance;     // Tolerance of parts sliding
rotation_clearance=fit_tolerance;  // Similar for rotational

infeed_tray_high=4;
outfeed_offset=0.65;       // Wheel to outfeed wedge.

nema_cutout=false;   // should we have a central cut-out for the nema17?

mount_panel_thickness=6;  // thickness of material for the frame, e.g. acrylic.
mount_panel_corner_r=6;

// Blades engaging with the button-holes
blade_h=3.5;
blade_w=0.7;
blade_l=4;

top_knife_pos
  = radius - knife_into_wheel
  + knife_slider_above_wire + (knife_slide_layers-knife_slide_top_layers)*knife_slide_layer_thick;

mount_hole_flush_with_top_knife
  = top_knife_pos - axle_dia/2-stack_spacer_wall
  - 2.5;  // To accomodate washer and nut.
panel_corner_flush_with_top_knife = top_knife_pos - mount_panel_corner_r;

mount_hole_next_to_knife_block = knife_slider_bottom_block_w/2
  + stack_spacer_wall + stack_spacer_rod_dia/2
  + 2*slide_tolerance;  // a bit more than usual because we dive into it.

// Places where we add spacers to rigidly hold together the two side-frames.
mount_holes = [
  [39, -radius+12], [36, radius],  // Infeed side
  [-30, -radius-3],                // Outfeed side
  // Top around knife slider.
  [mount_hole_next_to_knife_block, mount_hole_flush_with_top_knife],
  [-mount_hole_next_to_knife_block, mount_hole_flush_with_top_knife]];

mount_panel_corners = [
  [-39, -radius - 6],         // bottom, out-feed side
  [-39, 0], //[-30, +radius+idler_dia], // up out-feed side.
  [-mount_hole_next_to_knife_block, panel_corner_flush_with_top_knife],
  [mount_hole_next_to_knife_block, panel_corner_flush_with_top_knife], // summit
  [62, 0], [62, -radius - 6]];  // down, in-feed

echo("circumreference ", circ, "; radius=", radius, "; teeth=", bands_per_wheel*hole_count, "; inner-width: ", stack * band_thick + 2*side_wall_clearance, "; knife-rod-distance: ", stack * band_thick + side_wall_clearance);


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
  widening_r=spoke_slot + spoke_thick;
  hull() {
    translate([radius - from_edge, 0, -band_thick/2]) cylinder(r=widening_r, h=band_thick);
    translate([radius, 0, -band_thick/2]) cylinder(r=widening_r, h=band_thick);
  }
}

module spoke_cut_widening_punch(from_edge=cut_slot_deep) {
  translate([radius-from_edge, 0, -15]) hull() {
    cylinder(r=spoke_slot, h=30);
    translate([50, 0, 0]) cylinder(r=spoke_slot, h=30);
  }
}

module basic_wheel(extra=0) {
  // Outer cylinder, hollowed
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
          translate([radius/2, 0, 0]) cube([radius, spoke_thick+extra, band_thick], center=true);
        }
      }
      spoke_cut_widening();
    }

    translate([0, 0, -band_thick/2]) cylinder(r=radius, h=band_thick);
  }

  mount_place(dia=axle_dia+extra);  // axle in center
}

module wheel_assembly(extra=0) {
  difference() {
    basic_wheel(extra);
    spoke_cut_widening_punch();
    mount_place_punch(dia=axle_dia-extra);
  }

  for (a=[hole_angle/2:hole_angle:360-e]) {
    rotate([0, 0, a]) translate([radius-0.5, 0, 0]) button_hole_tooth();
  }
}

module wheel_stack(layers=stack, with_axle=false) {
  d=band_thick;
  axle_extra=side_wall_clearance+mount_panel_thickness + 10;
  for (i = [0:1:layers-e]) {
    translate([0, 0, i*d]) wheel_assembly();
  }

  if (with_axle) {
    // TODO: add motor mount thing and counter-nut.
    translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=layers*band_thick+2*axle_extra);
  }
}

// The knife is mostly non-3D printed, but made out of other materials
//  * the wire itself out of nichrome
//  * the connecting columns are some threaded rod.
module knife(s=stack) {
  d=band_thick;
  nd=8;   // nut dia
  nh=2.5; // nut height
  glow="orange";
  translate([-d/2, -0, 0]) {
    translate([-side_wall_clearance/2, 0, 0]) rotate([0, 90, 0]) color(glow)
      cylinder(r=0.5, h=s*d+side_wall_clearance);  // 'wire'

    translate([-side_wall_clearance/2, 0, 0]) {
      translate([0, 0, -3]) cylinder(r=4.5/2, h=60);  // rod
      color(glow) cylinder(r=5/2, h=1);
      translate([0, 0, knife_slider_above_wire-nh]) hex_nut(flat_dia=nd, h=nh);
      translate([0, 0, knife_slider_above_wire-2*nh]) rotate([0, 0, 17]) hex_nut(flat_dia=nd, h=nh); // counter nut.
      translate([0, 0, knife_slider_above_wire+knife_slide_len]) hex_nut(flat_dia=nd, h=nh, with_washer=true);
      translate([0, 0, knife_slider_above_wire+knife_slide_len+nh]) rotate([0, 0, 28]) hex_nut(flat_dia=nd, h=nh);
    }
    translate([s*d+side_wall_clearance/2, 0, 0]) {
      translate([0, 0, -3]) cylinder(r=4.5/2, h=60);
      color(glow) cylinder(r=5/2, h=1);
      translate([0, 0, knife_slider_above_wire-nh]) hex_nut(flat_dia=nd, h=nh);
      translate([0, 0, knife_slider_above_wire-2*nh]) rotate([0, 0, 38]) hex_nut(flat_dia=nd, h=nh); // counter nut.
      translate([0, 0, knife_slider_above_wire+knife_slide_len]) hex_nut(flat_dia=nd, h=nh, with_washer=true);
      translate([0, 0, knife_slider_above_wire+knife_slide_len+nh]) rotate([0, 0, 19]) hex_nut(flat_dia=nd, h=nh);
    }
    translate([0, 0, knife_slider_above_wire]) knife_slider();
  }
}

module knife_track_punch(wall_thick=3) {
  translate([-band_thick/2-wall_thick/2-side_wall_clearance, 0, 0]) union() {
    // TODO: move these to panel thing.
    spring_mount = 4;
    top = top_knife_pos+knife_movement+knife_slide_top_len+spring_mount;
    // top screw to hold spring
    translate([0, 0, top]) panel_corner(r=3.2/2, thick=wall_thick+2*e);
  }
}

module anim(s=4) {
  rotate([0, 0, 0]) {
    knife_anim_fraction = anim_phase(anim_t, 0, 0.6);
    wheel_anim_fraction = smooth_anim(anim_phase(anim_t, 0.6, 1));

    anim_rot_angle=180+wheel_anim_fraction*720;
    rotate([anim_rot_angle, 0, 0]) {
      rotate([0, 90, 0]) wheel_stack(s, with_axle=true);

      translate([-band_thick/2+stack*band_thick
                 +side_wall_clearance
                 -rotation_clearance, 0, 0])
        rotate([0, -90, 0]) motor_coupler();
    }

    down=sin(knife_anim_fraction*180) * knife_movement;
    // So OpenSCAD has this funny behavior, when something is touching it
    // makes the transparent thing less opaque ? Does it draw it twice or
    // something ? Anyway, let's not fully touch the shoulder and we're good.
    dont_touch_fully=e;
    translate([0, 0, radius + knife_movement - knife_into_wheel - down+dont_touch_fully])
      knife(s);
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

  axle_extra=side_wall_clearance + mount_panel_thickness + 5;
  if (with_axle) {
    translate([0, 0, -axle_extra])
      color("gray") cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
    translate([0, 0, -axle_extra+4]) retainer_clip(r=axle_dia/2);
    translate([0, 0, s*d+axle_extra-4]) retainer_clip(r=axle_dia/2);
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

module infeed_idler_stack(s=stack, print_distance=-1, with_axle=false,
                          gravity_holes=false, outer=infeed_idler_dia/2) {
  d = band_thick;
  color("blue") for (i = [0:1:s-e]) {
    is_last= (i == s-1);
    if (print_distance < 0) {
      translate([0, 0, i*d]) infeed_idler(outer, is_last=is_last);
    } else {
      translate([i*print_distance, 0, 0]) infeed_idler(outer, is_last=is_last);
    }
  }

  // ΤODO: this still seems too short by a tiny amount on one side. Is there
  // somewhere a fit-tolerance or something substracted ?
  axle_extra=side_wall_clearance + mount_panel_thickness + 5;
  translate([0, 0, -band_separation/2]) {
    if (with_axle) {
      translate([0, 0, -axle_extra])
        color("gray") cylinder(r=axle_display/2, h=s*d + 2*axle_extra);
      translate([0, 0, -axle_extra+4]) retainer_clip(r=axle_dia/2);
      translate([0, 0, s*d+axle_extra-4]) retainer_clip(r=axle_dia/2);
    }

    if (gravity_holes) {
      hull() {
        translate([1, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
        translate([-15, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
      }
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
  sw=side_wall_clearance+mount_panel_thickness;

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
  hinge_r=axle_dia/2+2;
  hull() {
    translate([-(hinge_thick+clearance), 0, 0]) rotate([0, 90, 0]) cylinder(r=hinge_r, h=hinge_thick);
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

module infeed_fancy_tray(s=stack, extra=0) {
  idler_r=idler_dia/2;
  tray_idler_distance=1;
  tray_idler_shift=5;
  tray_len=34;
  below=idler_r + infeed_tray_high + tray_idler_distance;

  translate([0, tray_idler_shift, -below])
    infeed_tray(s=s, len=tray_len, extra=extra);

  // Snap lock
  translate([0, tray_idler_shift+7, -below])
    snap_lock(h=8, l=tray_len-7, do_punch = (extra > 0));
  translate([s*band_thick, tray_idler_shift+7, -below])
    scale([-1, 1, 1]) snap_lock(h=8, l=tray_len-7, do_punch = (extra > 0));

  // hinge
  infeed_hinge(side_wall_clearance-2*rotation_clearance, rotation_clearance, tray_idler_distance, tray_idler_shift);
  // same, mirrored on other side.
  translate([s*band_thick, 0, 0]) scale([-1, 1, 1])
    infeed_hinge(side_wall_clearance-2*rotation_clearance, rotation_clearance, tray_idler_distance, tray_idler_shift);
}

module infeed_assembly(s=stack, correct_angle=0, extra=0, gravity_holes=false) {
  idler_r=idler_dia/2;
  translate([-band_thick/2, 0, 0]) rotate([correct_angle, 0, 0]) {
    rotate([0, 90, 0]) wheel_idler_stack(s, with_axle=true);
    infeed_fancy_tray(s, extra=extra);
  }

  // this    v-- is fudging it. Somewhere else this offset is broken
  translate([-band_thick/2+0.5+band_separation/2,
             30,
             0.5])
    rotate([0, 90, 0]) infeed_idler_stack(s=s, with_axle=true, gravity_holes=gravity_holes);
}

// All the mechanics combined: wheel and idlers.
module mechanics_assembly(s=2, gravity_holes=false, extra=0) {
  ia=-42;     // infeed angle relative to center radius
  id=radius+idler_dia/2 + 2; // infeed distance. 2mm away from main wheel.
  translate([0, cos(ia)*id, sin(ia)*id])
    infeed_assembly(s, 0, extra, gravity_holes=gravity_holes);

  // Idlers around the knife
  rotate([-20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) wheel_idler_stack(s, with_axle=true, gravity_holes=gravity_holes);
  rotate([20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) wheel_idler_stack(s, with_axle=true, gravity_holes=gravity_holes);

  // Outfeed
  rotate([45, 0, 0]) rotate([0, 0, 180]) color("violet") outfeed_stack(s, extra=extra);

  // Wheel + knife. Animatable.
  anim(s);

  // Spacers to mount assembly together.
  for (h = mount_holes) {
    translate([0, h[0], h[1]]) rotate([0, 90, 0])
      translate([0, 0, -band_thick/2-side_wall_clearance])
      stack_spacer();
  }
}

module panel_corner(r=mount_panel_corner_r, thick=3) {
  rotate([0, 90, 0]) translate([0, 0, -thick/2]) cylinder(r=r, h=thick);
}

module nema17_punch(h=50) {
  d=31/2;
  for (p = [[-d, -d], [d, -d], [d, d], [-d, d]]) {
    translate(p) cylinder(r=3.2/2, h=h);
  }
  if (nema_cutout) cylinder(r=22.5/2, h=h);
}

module mount_panel_slider_rail(thick=mount_panel_thickness) {
        hull() {
        slot_half=knife_slider_slot_w/2;
        top=top_knife_pos;
        spring_mount = 4;
        translate([-thick/2, -knife_slider_slot_w/2, top-e]) cube([thick, knife_slider_slot_w, e]);
        translate([0, -(slot_half-mount_panel_corner_r), top+knife_movement+knife_slide_top_len+spring_mount]) panel_corner(thick=thick);
        translate([0, +(slot_half-mount_panel_corner_r), top+knife_movement+knife_slide_top_len+spring_mount]) panel_corner(thick=thick);
      }
}

module mount_panel(thick=mount_panel_thickness, with_motor=false) {
  s=1;
  color("azure", 0.1) difference() {
    translate([-band_thick/2
               -side_wall_clearance
               -mount_panel_thickness/2, 0, 0]) {
      // The main body
      hull() {
        for (c = mount_panel_corners) {
          translate([0, c[0], c[1]]) panel_corner(thick=thick);
        }
      }

      // Where the top knife is sliding on.
      mount_panel_slider_rail(thick=thick);
    }
    mechanics_assembly(s, gravity_holes=true, extra=0.15);
    if (with_motor) rotate([0, -90, 0]) nema17_punch();

    // Knife slide
    knife_track_punch(wall_thick=thick);

    axle_extra=side_wall_clearance + mount_panel_thickness + 5;
    for (h = mount_holes) {
      translate([0, h[0], h[1]]) rotate([0, 90, 0])
        translate([0, 0, -band_thick/2-axle_extra])
        cylinder(r=axle_dia/2, h=s*band_thick+2*axle_extra);
    }
  }
}

module hollow_cylinder(r=10, axle_r=8, h=10, with_brim=false) {
  difference() {
    union() {
      cylinder(r=r, h=h);
      if (with_brim) cylinder(r=r+3, h=0.3);
    }
    translate([0, 0, -e]) cylinder(r=axle_r, h=h+2*e);
  }
}

module stack_spacer(s=stack, with_brim=false) {
  total_width = stack * band_thick + 2*side_wall_clearance;
  color("azure", 0.25) hollow_cylinder(r=axle_dia/2+stack_spacer_wall,
                                       axle_r=axle_dia/2,
                                       h=total_width,
                                       with_brim=with_brim);
}


// Useful outputting modules (TODO: should we add our own bottom support as
// it is not possible right now to brim on just one part in prusa-slicer?)
module print_stack_spacer(with_brim=true) {
  translate([0, 0, 0]) stack_spacer(with_brim=with_brim);
  translate([15, 0, 0]) stack_spacer(with_brim=with_brim);
  translate([30, 0, 0]) stack_spacer(with_brim=with_brim);
  translate([0, 15, 0]) stack_spacer(with_brim=with_brim);
  translate([15, 15, 0]) stack_spacer(with_brim=with_brim);
  translate([30, 15, 0]) stack_spacer(with_brim=with_brim);
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

module mount_panel_projection(with_motor=false) {
  projection(cut=true) {
    translate([0, 0, -side_wall_clearance-band_thick/2-1.5]) rotate([0, 90, 0]) mount_panel(with_motor=with_motor);
  }
}

module laser_cut_mount_panel() {
  mount_panel_projection(with_motor=true);
  translate([70, 80, 0]) rotate([0, 0, 180]) mount_panel_projection();
}

module laser_cut_knife_slider() {
  dist=knife_slider_bottom_block_w+1;
  for (i = [0:1:knife_slide_layers-knife_slide_top_layers-e]) {
    translate([0, i*dist+dist/2, 0]) projection(cut=true) knife_slider_layer(s=stack);
  }

  dist_large=knife_slider_slot_w + 2*knife_slider_ring_support + 1;
  for (i = [0:1:knife_slide_top_layers-e]) {
    translate([0, -i*dist_large-dist_large/2, 0]) projection(cut=true)
      knife_slider_layer(s=stack, is_top=true);
  }
}

module print_outfeed() {
  rotate([0, 180, 0]) outfeed_stack(stack);
}

module print_sidewall_clearance_distance_rings() {
  outer=axle_dia+4;
  place_dist=outer+0.1;
  pack_offset_x=cos(60) * place_dist;
  pack_offset_y=sin(60) * place_dist;
  for (row = [0:1:2-e]) {
    for (col = [0:1:3-e]) {
      // We need two for the outer rollers, the others are for the top idlers.
      height = side_wall_clearance + ((col == 0) ? band_separation/2 : 0)
        - rotation_clearance;  // These are always used on rotating parts.
      translate([row*place_dist + ((col % 2 == 0) ? pack_offset_x : 0),
                 col*pack_offset_y, 0])
        hollow_cylinder(r=outer/2, axle_r=axle_dia/2, h=height);
    }
  }
}

module full_assembly(with_stack_nuts=true) {
  mechanics_assembly(stack);

  // Motor mounted on side.
  translate([stack*band_thick - band_thick/2   // We mount motor on other side
             + side_wall_clearance
             + mount_panel_thickness, 0, 0]) nema_motor_stand();

  // The floating axle holder on the other side, holding onto that frame
  // perpendicularly with nuts.
  translate([-band_thick/2
             -side_wall_clearance
             -mount_panel_thickness, 0, 0]) rotate([0, -90, 0]) motor_opposing_bearing_nut(show_nut=true);
  translate([-band_thick/2
             -side_wall_clearance,
              0, 0]) rotate([0, 90, 0]) motor_opposing_bearing();

  if (with_stack_nuts) {
    for (h = mount_holes) {
      translate([0, h[0], h[1]])
        translate([-band_thick/2
                   -side_wall_clearance
                   -mount_panel_thickness, 0, 0])
        rotate([0, -90, 0])
        hex_nut(axle_hex_flat_size, axle_hex_thick, with_washer=true,
                show_screw_dia=axle_dia);
      translate([0, h[0], h[1]])
        translate([stack*band_thick-band_thick/2
                   +side_wall_clearance
                   +mount_panel_thickness, 0, 0])
        rotate([0, 90, 0])
        hex_nut(axle_hex_flat_size, axle_hex_thick, with_washer=true,
                show_screw_dia=axle_dia);
    }
  }

  // Panel sides. We need to put them last, so that they are transparent to
  // all the things we add above. Weird OpenSCAD thing ?
  mount_panel(thick=mount_panel_thickness);

  // The other side has the motor mount.
  translate([stack*band_thick + 2*side_wall_clearance+mount_panel_thickness, 0, 0]) mount_panel(thick=mount_panel_thickness, with_motor=true);

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
  below_center=radius + 6 + mount_panel_corner_r;
  motor_deep=49;
  flange_thick=2.1;
  d=31/2;      // Distance of nema holes.
  corner_r=5;
  motor_body_size=42.2;   // Nominal 1.7"
  center_hole=22.2;
  cable_w=9;
  cable_from_front=38 + flange_thick;
  cable_deep=15;  // just long enough to punch out at the back;

  // Infeed assembly position. We need this to cut out enough from the motor
  // block for an axle to mount.
  // TODO: this is copy/pasted from mechanics assembly and
  // should come from one place
  ia=-42;     // infeed angle relative to center radius
  id=radius+idler_dia/2 + 2; // infeed distance. 2mm away from main wheel.
  infeed_idler_punch_x=cos(ia)*id;
  infeed_idler_punch_y=sin(ia)*id;

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

      // Space for the infeed-idler
      translate([-infeed_idler_punch_y, infeed_idler_punch_x, 0]) cylinder(r=axle_hex_flat_size / cos(30) / 2 + 1, h=motor_deep+2*e);
    }
  }
  translate([radius+4, 0, 0]) rotate([0, -90, 0])
    pcb_rails(len=motor_deep-10, outer_w=35.5, inner_w=15);
}

module nema_motor_stand() {
  rotate([0, 90, 0]) print_nema_motor_stand();
}

// Coupling motor. For now manual to work with plain wheel, but later
// should be fused with wheel.
module motor_coupler() {
  motor_axle=5.2;
  engage_height=5;
  height=side_wall_clearance - rotation_clearance + engage_height;
  coupler_dia=16;

  color("yellow") translate([0, 0, height]) rotate([0, 180, 0]) difference() {
    cylinder(r=coupler_dia/2, h=height);
    translate([0, 0, -band_thick/2+engage_height])
      wheel_assembly(extra=fit_tolerance);
    translate([0, 0, -e]) cylinder(r=motor_axle/2, h=height+2*e);
    translate([0, -coupler_dia/2, engage_height+side_wall_clearance/2]) rotate([-90, 0, 0]) m3_screw(len=coupler_dia/2, nut_at=2.5, nut_channel=10);
  }
}

// 'Bearing' on the other side of the motor. With that, we essentiall just
// use a threaded rod mounted pretty perpendicular to the frame. And for that
// we need a wide diameter flat 'nut'.
module motor_opposing_bearing() {
  mount_dia=20;
  big_height=side_wall_clearance - 4;

  color("red") difference() {
    union() {
      cylinder(r=axle_dia/2 + 2, h=side_wall_clearance-rotation_clearance);
      cylinder(r=mount_dia/2, h=big_height);
    }
    translate([0, 0, -e]) cylinder(r=axle_dia/2, h=side_wall_clearance+e);
    translate([0, 0, (big_height-axle_hex_thick)/2])
      hex_nut(axle_hex_flat_size, axle_hex_thick, channel_len=10);
  }
}

module motor_opposing_bearing_nut(show_nut=false) {
  mount_dia=20;
  thick=axle_hex_thick + 3;
  color("red") difference() {
    cylinder(r=mount_dia/2, h=thick);
    translate([0, 0, -e]) cylinder(r=axle_dia/2, h=thick+2*e);
    translate([0, 0, thick-axle_hex_thick]) hex_nut(axle_hex_flat_size, axle_hex_thick+e);
    // 'finger tightening'
    for (a = [0:120:360]) {
      rotate([0, 0, a+30]) translate([mount_dia/2+5, 0, 3]) cylinder(r=8, h=thick+2*e);
    }
  }
  if (show_nut) {
    translate([0, 0, thick-axle_hex_thick]) hex_nut(axle_hex_flat_size-fit_tolerance, axle_hex_thick-0.6);
  }
}

module print_motor_bearing_parts() {
  motor_opposing_bearing();
  translate([21, 0, 0]) motor_opposing_bearing_nut();
}

module knife_slider_layer(s=stack, is_top=false) {
  outer_support=knife_slider_ring_support;
  bar_wide=is_top
    ? knife_slider_slot_w + 2*outer_support
    : knife_slider_bottom_block_w;
  poke_w=knife_slider_slot_w - fit_tolerance;
  inner_length=s*band_thick + 2*side_wall_clearance - 2*fit_tolerance;
  outer_extras=2*(mount_panel_thickness+fit_tolerance+outer_support);
  outer_length=is_top ? inner_length+outer_extras : inner_length;

    translate([(s*band_thick/2+side_wall_clearance/2)-side_wall_clearance/2, 0, knife_slide_layer_thick/2]) difference() {
      if (is_top) {
        rounded_cube([outer_length, bar_wide, knife_slide_layer_thick], center=true);
      } else {
        cube([outer_length, bar_wide, knife_slide_layer_thick], center=true);
      }

    if (is_top) {
      inner_thick=mount_panel_thickness+2*slide_tolerance;
      inner_bw=bar_wide-2*outer_support+2*slide_tolerance;
      translate([-(outer_length/2-outer_support-inner_thick/2+slide_tolerance), 0, 0]) cube([inner_thick, inner_bw, knife_slide_layer_thick+2*e], center=true);
      translate([+(outer_length/2-outer_support-inner_thick/2+slide_tolerance), 0, 0]) cube([inner_thick, inner_bw, knife_slide_layer_thick+2*e], center=true);
    }

    // Holes for the rods
    translate([+(s*band_thick/2+side_wall_clearance/2), 0, -knife_slide_layer_thick/2-e]) cylinder(r=knife_slide_rod_hole/2, h=knife_slide_layer_thick+2*e);
    translate([-(s*band_thick/2+side_wall_clearance/2), 0, -knife_slide_layer_thick/2-e]) cylinder(r=knife_slide_rod_hole/2, h=knife_slide_layer_thick+2*e);
  }
}

// This is to be cut out of three layers of 3mm plywood. The rods get slightly
// warm, which might soften over time 3D printed plastic.
module knife_slider(s=stack) {
  for (i = [0:1:knife_slide_layers-e]) {
    color(i % 2 == 0 ? "#d8c0a3" : "#c9a77e")  // 'wood' layers
    translate([0, 0, i*knife_slide_layer_thick])
      knife_slider_layer(s, is_top = (i > knife_slide_layers-knife_slide_top_layers-1));
  }
}

// For some reason, OpenSCAD only can deal with assigning things to $vpr
// in the toplevel. So to enable/disable this, we can't wrap it in if (),
// but need to comment it out. So remove comment when generate animation.
// Also the reason why we have to nest it in multiple ?: operators.
//
// Note, within each of the intervals, the anim_t moves from 0..1, so we can
// use that for selecting knife/rotation phase.
/*
$vpr
  = in_interval($t, 0.00, 0.20)
  ? [ 85, 0, -80]
  // Here, we move the camera while the knife is moving (0..0.6)
  : in_interval($t, 0.20, 0.40)
  ? [ scale_range(smooth_anim(anim_phase(anim_t, 0, 0.6)), 85, 76),
      0,
      scale_range(smooth_anim(anim_phase(anim_t, 0, 0.6)), -80, 50)]
  // Here, we want to move during the rotation (0.6..1), move to back
  : in_interval($t, 0.40, 0.60)
  ? [ scale_range(smooth_anim(anim_phase(anim_t, 0.6, 1)), 76, 43),
      0,
      scale_range(smooth_anim(anim_phase(anim_t, 0.6, 1)), 50, 180)]
  : in_interval($t, 0.60, 0.80)
  ? [ scale_range(smooth_anim(anim_phase(anim_t, 0.6, 1)), 43, 85),
      0,
      scale_range(anim_phase(anim_t, 0.6, 1), 180, 300)]
  : [ 85, 0, -80];  // Remaining time: just one phase staying put.
*/

full_assembly();
