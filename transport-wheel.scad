$fn=96;
e=0.02;

PI=3.1415926536;

bands_per_wheel=0.5;
cut_slot_deep=10;
axle_dia=6.5;   // 1/4" rod + extra
axle_display=axle_dia - 0.5;
mount_hole_dia=4.5;
mount_hole_pos=5;  // from outside
spoke_angle=60;
do_screws=false;
do_spokes=true;
support_wheel_axle=5;

wheel_wall=1;
spoke_thick=1;

band_separation=1;
band_thick=19.5 + band_separation;
//band_center_thick=12;
band_center_thick=band_thick;


side_wall_clearance=10;

hole_count=18;   // This determines the length
hole_angle=360/(bands_per_wheel*hole_count);

//button_hole_distance=286/17;  // measured mm / hole count.
//button_hole_distance=594/35;  // measured mm / hole count.
button_hole_distance=25.4 / 1.5;  // probably actual value.
circ=bands_per_wheel * hole_count * button_hole_distance;
radius=circ / (2*PI);

blade_h=3.5;
blade_w=0.9;
blade_l=5;

echo("circumreference ", circ, "; radius=", radius, "; teeth=", bands_per_wheel*hole_count);

module mount_place(dia=mount_hole_dia) {
     translate([0, 0, -band_thick/2]) cylinder(r=dia/2 + 2, h=band_thick);
}

module mount_place_punch(dia=mount_hole_dia) {
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
	  if (do_screws) {
	       for (a = [-5, 5]) {
		    rotate([0, 0, a]) translate([radius-mount_hole_pos, 0, 0]) mount_place();
	       }
	  } else {
	       translate([radius, 0, -band_thick/2]) cylinder(r=widening_r, h=band_thick);
	  }
     }
}

module spoke_cut_widening_punch(from_edge=cut_slot_deep) {
     translate([radius-from_edge, 0, -15]) hull() {
	  cylinder(r=2, h=30);
	  translate([50, 0, 0]) cylinder(r=2, h=30);
     }
}

module basic_wheel() {
     translate([0, 0, -band_center_thick/2]) difference() {
	  cylinder(r=radius, h=band_center_thick);
	  translate([0, 0, -e]) cylinder(r=radius-wheel_wall, h=band_center_thick+2*e);
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
			 if (do_spokes) translate([radius/2, 0, 0]) cube([radius, spoke_thick, band_center_thick], center=true);
		    }
	       }

	       spoke_cut_widening();

	       // Spoke mounts
	       if (do_screws) {
		    for (a=[spoke_angle:spoke_angle:179]) {
			 rotate([0, 0, a]) translate([radius-mount_hole_pos, 0, 0]) mount_place();
			 rotate([0, 0, -a]) translate([radius-mount_hole_pos, 0, 0]) mount_place();
		    }

		    for (a = [-5, 5, 175, 185]) {
			 rotate([0, 0, a]) translate([radius-mount_hole_pos, 0, 0]) mount_place();
		    }
	       }

	  }

	  translate([0, 0, -band_thick/2]) cylinder(r=radius, h=band_thick);
     }

     if (do_spokes) mount_place(dia=axle_dia);  // axle in center
}

module wheel_assembly() {
     difference() {
	  basic_wheel();
	  spoke_cut_widening_punch();
	  if (do_screws) {
	       for (a=[spoke_angle:spoke_angle:179]) {
		    rotate([0, 0, a]) translate([radius-mount_hole_pos, 0, 0]) mount_place_punch();
		    rotate([0, 0, -a]) translate([radius-mount_hole_pos, 0, 0]) mount_place_punch();
	       }
	       for (a = [-5, 5, 175, 185]) {
		    rotate([0, 0, a]) translate([radius-mount_hole_pos, 0, 0]) mount_place_punch();
	       }
	  }
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

	  rotate([90, 0, 180]) rotate([0, -90, 0]) color("darkgray") tangential_band(r=radius, band_wide=band_thick-band_separation-1, in_angle=45, out_angle=135, total_len=500, start_len=481.5-t*button_hole_distance*hole_count);
     }
}

//wheel_assembly();
//stack(1);

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

module support_wheel(is_first=false, is_last=false) {
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

module support_wheel_stack(s=5, print_distance=-1, with_axle=false, gravity_holes=false) {
     d = band_thick;
     color("blue") for (i = [0:1:s+1-e]) {
	  is_first=(i == 0);
	  is_last = (i == s);
	  if (print_distance < 0) {
	       translate([0, 0, is_first ? 0 : (i-0.5)*d+1.5])
		    support_wheel(is_first=is_first, is_last=is_last);
	  } else {
	       translate([i*print_distance, 0, 0])
		    support_wheel(is_first=is_first, is_last=is_last);
	  }
     }
     axle_extra=side_wall_clearance + 10;
     if (with_axle) {
	  color("gray") translate([0, 0, -axle_extra]) cylinder(r=axle_display/2, h=s*d+2*axle_extra);
     }
     if (gravity_holes) {
	  hull() {
	       translate([3, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
	       translate([-15, 0, -axle_extra]) cylinder(r=axle_dia/2, h=s*d+2*axle_extra);
	  }
     }
}

module band_tray(s=5, len=60, extra=0) {
     color("silver") for (i = [0:1:s-e]) {
	  translate([i*band_thick, 0, 0]) {
	       cube([band_thick, len, 1]);
	       cube([band_separation/2, len, 4]);
	       translate([band_thick-band_separation/2, 0, 0])
		    cube([band_separation/2+e, len, 4]);
	  }
     }
     sw_r=4/2 + extra;
     sw=side_wall_clearance+4;
     translate([-sw, 0, 0]) hull() {
	  translate([0, 10, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
	  translate([0, 30, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
     }
     translate([s*band_thick, 0, 0]) hull() {
	  translate([0, 10, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
	  translate([0, 30, 4/2]) rotate([0, 90, 0]) cylinder(r=sw_r, h=sw);
     }

     //cube([side_wall_clearance, 30, 4]);
}

module tray_wheel() {
     outer=9;
     difference() {
	  union() {
	       cylinder(r=outer, h=band_thick-band_separation-1);
	       cylinder(r=outer-5, h=band_thick);
	  }
	  translate([0, 0, -e]) cylinder(r=axle_dia/2, h=band_thick+2*e);
     }
}

module tray_wheel_stack(s=5, print_distance=-1, with_axle=false, gravity_holes=false) {
     d = band_thick;
     color("blue") for (i = [0:1:s-e]) {
	  if (print_distance < 0) {
	       translate([0, 0, i*d]) tray_wheel();
	  } else {
	       translate([i*print_distance, 0, 0]) tray_wheel();
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

module out_feed() {
     offset=0.5;
     difference() {
	  translate([-band_thick/2, offset, radius+offset]) {
	       translate([0, 2, -1]) cube([band_thick, 30, 1]);
	       translate([0, 2, -5]) cube([band_thick, 15, 5]);
	  }
	  rotate([0, 90, 0]) translate([0, 0, -band_thick/2-e]) cylinder(r=radius+offset, h=band_thick+2*e);
	  rotate([0, 90, 0]) translate([0, 0, -2-e]) cylinder(r=radius+offset+5, h=4+2*e);
     }
}

module out_feed_stack(s=3, extra=0) {
     d = band_thick;
     for (i = [0:1:s-e]) {
	  translate([-d*i, 0, 0]) out_feed();
     }
     sw_r=4/2+extra;
     sw=side_wall_clearance+4;
     translate([-d*s+d/2-sw, 0, 0]) hull() {
	  translate([0, 19, radius-4/2+0.5]) rotate([0, 90, 0]) cylinder(r=sw_r, h=2*sw+d*s);
	  translate([0, 32, radius-4/2+0.5]) rotate([0, 90, 0]) cylinder(r=sw_r, h=2*sw+d*s);

     }
}

//tooth_wheel();
//half_wheel();
//anim(5);

module support_wheel_printing() {
     support_wheel_stack(s=wheel_stack, print_distance=25);
     translate([0, 25, 0]) support_wheel_stack(s=wheel_stack, print_distance=25);
     translate([0, 2*25, 0]) tray_wheel_stack(s=wheel_stack, print_distance=25);
}

module tangential_band(r=30, in_angle=22, out_angle=90,
		       band_wide=20, start_len=470, total_len=500) {
     thick=1;
     circumreference=2*PI*r;
     wheel_len=(out_angle-in_angle)/360 * circumreference;
     max_wrap_wheel = total_len - start_len;
     echo ("Wheel len:", wheel_len, "; max wrap:", max_wrap_wheel);
     out_len=total_len - start_len - wheel_len;
     translate([0, 0, -band_wide/2]) {
	  rotate([0, 0, in_angle]) translate([r, -start_len, 0]) cube([thick, start_len, band_wide]);
	  rotate([0, 0, out_angle]) translate([r, 0, 0]) cube([thick, out_len, band_wide]);
	  degree_step=1;
	  segment_len=circumreference*degree_step/360;
	  for (range = [0:degree_step:out_angle-in_angle+degree_step/2]) {
	       a = in_angle + range;
	       if (range/degree_step * segment_len <= max_wrap_wheel)
		    rotate([0, 0, a]) translate([r, -segment_len/2, 0]) cube([thick, segment_len+e, band_wide]);
	  }
     }
}

module mechanics_assembly(wheel_stack=2, gravity_holes=false, extra=0) {
     rotate([0, 0, 0]) {
	  rotate([-45, 0, 0]) {
	       translate([-band_thick/2, 15, radius-0.8]) band_tray(s=wheel_stack, len=40, extra=extra);
	       translate([-band_thick/2+(band_separation+1)/2, 30, radius+9+0.8]) rotate([0, 90, 0]) tray_wheel_stack(s=wheel_stack, with_axle=true, gravity_holes=gravity_holes);
	  }
     }
     rotate([-20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) support_wheel_stack(wheel_stack, with_axle=true, gravity_holes=gravity_holes);
     rotate([20, 0, 0]) translate([-band_thick/2, 0, radius+8+1]) rotate([0, 90, 0]) support_wheel_stack(wheel_stack, with_axle=true, gravity_holes=gravity_holes);

     anim(wheel_stack);
     rotate([45, 0, 0]) rotate([0, 0, 180]) color("violet") out_feed_stack(wheel_stack, extra=extra);
}

module panel_corner(r=4, thick=3) {
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
     difference() {
	  translate([-band_thick/2-1.5-side_wall_clearance, 0, 0]) hull() {
	       translate([0, -45, -radius - 5]) panel_corner(thick=thick);
	       translate([0, 60, -radius - 5]) panel_corner(thick=thick);
	       translate([0, 60, +radius]) panel_corner(thick=thick);
	       translate([0, -5, +radius+50]) panel_corner(thick=thick);
	       translate([0, +5, +radius+50]) panel_corner(thick=thick);
	       translate([0, -40, +radius+20]) panel_corner(thick=thick);
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
	  translate([0, -30, -radius-2]) rotate([0, 90, 0]) translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=s*band_thick+2*axle_extra);
	  translate([0, 40, -radius-2]) rotate([0, 90, 0]) translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=s*band_thick+2*axle_extra);
	  translate([0, 40, radius+10]) rotate([0, 90, 0]) translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=s*band_thick+2*axle_extra);
	  translate([0, -28, radius+5]) rotate([0, 90, 0]) translate([0, 0, -band_thick/2-axle_extra]) cylinder(r=axle_dia/2, h=s*band_thick+2*axle_extra);

     }
}

module mount_panel_2d() {
     projection(cut=true) {
	  translate([0, 0, -side_wall_clearance-band_thick/2-1.5]) rotate([0, 90, 0]) mount_panel(1);
     }
}

mount_panel_2d();
//mechanics_assembly(2);
//mount_panel(thick=2);

//out_feed_stack(2);
//tangential_band();
//support_wheel_printing();
//stack(wheel_stack);
//support_enforder(wheel_stack);
//band_tray(2);