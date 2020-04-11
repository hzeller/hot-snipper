$fn=96;
e=0.02;

PI=3.1415926536;

mount_hole_dia=4;

wall=1;
band_thick=19.5;
cremp=5;
spoke_thick=2;

hole_count=18;
hole_angle=360/(2*hole_count);

//button_hole_distance=286/17;  // measured mm / hole count.
//button_hole_distance=594/35;  // measured mm / hole count.
button_hole_distance=25.4 / 1.5;  // probably actual value.
circ=2 * hole_count * button_hole_distance;
radius=circ / (2*PI);

blade_h=3;
blade_w=0.8;
blade_l=6;

echo("circumreference ", circ, "; radius=", radius);

module mount_place(dia=mount_hole_dia) {
     cylinder(r=dia/2 + 2, h=band_thick+wall);
}

module mount_place_punch(dia=mount_hole_dia) {
     translate([0, 0, -e]) cylinder(r=dia/2, h=band_thick+wall+2*e);
}

module hole_retainer() {
     color("yellow") hull() {
	  cube([e, blade_l, blade_w], center=true);
	  translate([1, 0, 0]) cube([e, 6, blade_w], center=true);
	  translate([blade_h, 0, 0]) cube([e, 4, blade_w], center=true);
     }
}

module spoke_cut_widening_part(from_edge) {
     hull() {
	  translate([radius - from_edge, 0, 0]) cylinder(r=6, h=band_thick+wall);
	  translate([radius, 0, 0]) cylinder(r=6, h=band_thick+wall);
     }
}
module spoke_cut_widening(from_edge=20) {
     spoke_cut_widening_part(from_edge);
     rotate([0, 0, 180]) spoke_cut_widening_part(from_edge);
}

module spoke_cut_widening_punch_part(from_edge) {
     translate([radius-from_edge, 0, -1]) hull() {
	  cylinder(r=2, h=30);
	  translate([50, 0, 0]) cylinder(r=2, h=30);
     }
}
module spoke_cut_widening_punch(from_edge=20) {
     spoke_cut_widening_punch_part(from_edge);
     rotate([0, 0, 180]) spoke_cut_widening_punch_part(from_edge);
}

module basic_wheel() {
     difference() {
	  union() {
	       cylinder(r=radius+cremp, h=wall);
	       cylinder(r=radius, h=band_thick+wall);

	  }
	  translate([0, 0, -e]) cylinder(r=radius-2, h=band_thick+wall+2*e);
     }

     // spokes.
     intersection() {
	  union() {
	       for (a=[0:45:180]) {
		    rotate([0, 0, a]) translate([-radius, -spoke_thick/2, 0]) cube([2*(radius), spoke_thick, band_thick+wall]);
		    rotate([0, 0, a]) translate([radius-30, 0, 0]) mount_place();
		    rotate([0, 0, -a]) translate([radius-30, 0, 0]) mount_place();
	       }
	       spoke_cut_widening(from_edge=30);
	  }

	  cylinder(r=radius, h=band_thick+wall);
     }

     mount_place(dia=8.2);
}

module wheel_assembly() {
     difference() {
	  basic_wheel();
	  spoke_cut_widening_punch();
	  for (a=[0:45:180]) {
	       rotate([0, 0, a]) translate([radius-30, 0, 0]) mount_place_punch();
	       rotate([0, 0, -a]) translate([radius-30, 0, 0]) mount_place_punch();
	  }
	  mount_place_punch(dia=8.2);
     }
     if (true) for (a=[hole_angle/2:hole_angle:360-e]) {
	       rotate([0, 0, a]) translate([radius-0.5, 0, wall+band_thick/2]) hole_retainer();
	  }

}

module just_nupsies() {
intersection() {
     wheel_assembly();
     translate([0, 0, wall+band_thick/2]) cube([300, 300, blade_w], center=true);
}
}

module just_wall() {
     intersection() {
	  wheel_assembly();
	  translate([0, 0, wall/2]) cube([300, 300, wall], center=true);
     }
}

module stack(layers=3) {
     d=wall+band_thick;
     for (i = [0:1:layers-e]) {
	  translate([0, 0, i*d]) wheel_assembly();
     }
     translate([0, 0, layers*d]) just_wall();
}

module knife(layers=3, anim_stage=0) {
     down=sin(anim_stage*180) * 15;
     d=wall+band_thick;
     translate([-10, 0, radius+10-down]) color("red") cube([layers*d+20, 1, 30]);
}

module anim() {
     t=$t;
     rotate([(t < 0.8) ? (t/0.8) * 180 : 0, 0, 0]) rotate([0, 90, 0]) stack(4);
     knife(4, anim_stage = (t > 0.8) ? (t-0.8)/0.2 : 0);
}

wheel_assembly();
