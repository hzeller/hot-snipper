$fn=96;
e=0.02;

PI=3.1415926536;

bands_per_wheel=4/3;
cut_slot_deep=10;
axle_dia=6.5;   // 1/4" rod + extra
mount_hole_dia=4.5;
mount_hole_pos=5;  // from outside
spoke_angle=45;
do_screws=false;
do_spokes=true;
support_wheel_axle=5;

wheel_wall=0.6;
spoke_thick=0.6;

band_separation=1;
band_thick=19.5 + band_separation;
//band_center_thick=12;
band_center_thick=band_thick;



hole_count=18;   // This determines the length
hole_angle=360/(bands_per_wheel*hole_count);

//button_hole_distance=286/17;  // measured mm / hole count.
//button_hole_distance=594/35;  // measured mm / hole count.
button_hole_distance=25.4 / 1.5;  // probably actual value.
circ=bands_per_wheel * hole_count * button_hole_distance;
radius=circ / (2*PI);

blade_h=3;
blade_w=0.9;
blade_l=6;

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
	  translate([1, 0, 0]) cube([e, 6, blade_w], center=true);
	  translate([blade_h, 0, 0]) cube([e, 4, blade_w], center=true);
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
			 spoke_cut_widening();
		    }
	       }

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
	  for (a=[0:spoke_angle:360]) {
	       rotate([0, 0, a]) spoke_cut_widening_punch();
	  }

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

module tooth_wheel() {
     intersection() {
	  wheel_assembly();
	  cube([300, 300, blade_w], center=true);
     }
}

module half_wheel() {
     intersection() {
	  wheel_assembly();
	  translate([0, 0, (30+blade_w)/2]) cube([300, 300, 30], center=true);
     }
}

module stack(layers=3) {
     d=band_thick;
     for (i = [0:1:layers-e]) {
	  translate([0, 0, i*d]) wheel_assembly();
     }
}

module knife(layers=3, anim_stage=0) {
     side=10;
     down=sin(anim_stage*180) * 15;
     d=band_thick;
     translate([-side-d/2, -0.5, radius+10-down]) color("red") cube([layers*d+(2*side), 1, 30]);
     rotate([-13, 0, 0]) translate([-band_thick/2, 0, radius+10]) rotate([0, 90, 0]) support_wheel_stack(layers);
     rotate([13, 0, 0]) translate([-band_thick/2, 0, radius+10]) rotate([0, 90, 0]) support_wheel_stack(layers);
}

module anim(s=4) {
     t=$t;
     rotate([0, 0, 0]) {
	  rotate([((t < 0.8) ? (t/0.8) * -270 : 0), 0, 0]) rotate([0, 90, 0]) stack(s);
	  rotate([-90, 0, 0]) knife(s, anim_stage = (t > 0.8) ? (t-0.8)/0.2 : 0);
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
     big_part=(is_first || is_last)
	  ? (band_thick-center_free)/2
	  : (band_thick-center_free);
     difference() {
	  union() {
	       cylinder(r=10, h=big_part);
	       if (!is_last) cylinder(r=8, h=big_part+center_free);
	  }
	  translate([0, 0, -e]) cylinder(r=axle_dia/2, h=band_thick+2*e);
     }
}

module support_wheel_stack(s=5, print_distance=-1) {
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
}

module band_tray(s=5, len=60) {
     color("silver") for (i = [0:1:s-e]) {
	  translate([i*band_thick, 0, 0]) {
	       cube([band_thick, len, 0.8]);
	       cube([band_separation/2, len, 4]);
	       translate([band_thick-band_separation/2, 0, 0])
		    cube([band_separation/2+e, len, 4]);
	  }
     }
}

module tray_wheel() {
     difference() {
	  union() {
	       cylinder(r=10, h=band_thick-band_separation-1);
	       cylinder(r=5, h=band_thick);
	  }
	  translate([0, 0, -e]) cylinder(r=axle_dia/2, h=band_thick+2*e);
     }
}

module tray_wheel_stack(s=5, print_distance=-1) {
     d = band_thick;
     for (i = [0:1:s-e]) {
	  if (print_distance < 0) {
	       translate([0, 0, i*d]) tray_wheel();
	  } else {
	       translate([i*print_distance, 0, 0]) tray_wheel();
	  }
     }
}

module support_enforder(s=5) {
     translate([0, 0, -band_thick/2]) difference() {
	  cylinder(r=radius+3.5, h=s*band_thick);
	  translate([0, 0, -e]) cylinder(r=radius+2.5, h=s*band_thick+2*e);
     }
}

//tooth_wheel();
//half_wheel();
//anim(5);

wheel_stack=2;

if (true) {
     rotate([0, 0, 0]) {
	  translate([-band_thick/2, 0, -radius-4]) band_tray(s=wheel_stack);
	  //translate([-band_thick/2+(band_separation+1)/2, 40, radius+10+0.8]) rotate([0, 90, 0]) color("blue") tray_wheel_stack();
     }
     anim(wheel_stack);
}

//stack(wheel_stack);
//band_tray();
//support_wheel_stack(s=5, print_distance=25);
//translate([0, 25, 0]) support_wheel_stack(s=5, print_distance=25);
