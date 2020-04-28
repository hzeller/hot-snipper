// -*- mode: scad; c-basic-offset: 2; indent-tabs-mode: nil; -*-
// (c) 2020 Henner Zeller <h.zeller@acm.org>
//
// This file is provided under the license condition of Creative Commons BY-SA
// https://creativecommons.org/licenses/by-sa/4.0/

e=0.01;
fit_tolerance=0.3;                 // Tolerance of parts in contact.

// Scales range between 0..1 to from..to
function scale_range(t, from, to) = t * (to - from) + from;

// If t falls within the scene_start...scene_end range, scale linearly
// between these and return 0..1. if t < scene_start, return 0,
// if t > scene_end, return 1
function anim_phase(t, scene_range = [0, 1])
  = ((t < scene_range[0]) ? 0.0
     : (t >= scene_range[1] ? 1.0
        : (t - scene_range[0])/(scene_range[1] - scene_range[0])));

// Returns an S-curve animation range between 0..1 (just a piece of cos())
function smooth_anim(t) = (-cos(t*180) + 1)/2;

function in_interval(x, from, to) = (x >= from && x < to);

// Model a hex nut with the distance between the flat faces of flat_dia.
// If channel_len is given, provides a sideways channel.
module hex_nut(flat_dia, h, channel_len=-1,
               with_washer=false, washer_thick=0.7,
               show_screw_dia=-1) {
  r = flat_dia / cos(30) / 2;
  color("silver") cylinder(r=r, h=h, $fn=6);
  if (show_screw_dia > 0) color("darkgray") cylinder(r=show_screw_dia/2, h=h+e);
  if (with_washer) color("darkgray") cylinder(r=r, h=washer_thick);
  if (channel_len > 0) {
    translate([0, -flat_dia/2, 0]) cube([channel_len, flat_dia, h]);
  }
}

module rounded_cube(d=[10,10,10], center=false, r=3) {
     translate([center ? -d[0]/2 : 0,
		center ? -d[1]/2 : 0,
		center ? -d[2]/2 : 0]) hull() {
	  translate([r, r, 0]) cylinder(r=r, h=d[2]);
	  translate([d[0] - r, r, 0]) cylinder(r=r, h=d[2]);
	  translate([r, d[1]-r, 0]) cylinder(r=r, h=d[2]);
	  translate([d[0]-r, d[1]-r, 0]) cylinder(r=r, h=d[2]);
     }
}

// m3_screw space occupied by a M3 screw with optional nut and
// nut-access channel. Screw is centered around the Z-axis, with the
// screw in the positive and screw-head in the negative range.
// nut_at: start of where a m3 nut shoud be placed. -1 for off.
// nut_channel: make a channel of given length to slide a nut in.
//              nut channel extends in negative Y direction. Rotate as needed.
module m3_screw(len=60, nut_at=-1, nut_channel=-1) {
  m3_dia=3.4;         // Let it a little loose to not overconstrain things.
  m3_head_dia=6;
  m3_head_len=3;
  m3_nut_flat_dia=5.4 + 2*fit_tolerance;
  m3_nut_dia=5.4 / cos(30) + 2*fit_tolerance;  // /= cos(30) for circumcircle
  m3_nut_thick=2.8;

  cylinder(r=m3_dia/2, h=len);
  translate([0, 0, -20+e]) cylinder(r=m3_head_dia/2, h=20);
  if (nut_at >= 0) {
    translate([0, 0, nut_at]) {
      rotate([0, 0, -90]) hex_nut(flat_dia=m3_nut_flat_dia, h=m3_nut_thick,
        channel_len=nut_channel);
    }
  }
}

module retainer_clip(r=5, h=0.5) {
  width=1.2;
  gap=0.4;
  color("#505050") translate([0, 0, -h/2]) difference() {
    union() {
      cylinder(r=r+width, h=h);
      translate([-(3*width)/2, 0, 0]) cube([3*width, r+2*width, h]);
    }
    translate([0, 0, -e]) {
      cylinder(r=r, h=h+2*e);
      translate([-gap, 0, 0]) cube([2*gap, r+2*width+e, h+2*e]);
      translate([+(width-gap/2), r+1.3*width, 0]) cylinder(r=0.5, h=h+2*e);
      translate([-(width-gap/2), r+1.3*width, 0]) cylinder(r=0.5, h=h+2*e);
    }
  }
}
