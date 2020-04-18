ALL_TARGETS=fab/mount_panel.stl \
     fab/wheel_stack.stl fab/support_enforder.stl \
     fab/print_wheel_idler.stl fab/print_infeed_weight_idler.stl \
     fab/infeed_fancy_tray.stl fab/print_outfeed.stl \
     fab/print_stack_spacer.stl \
     fab/print_sidewall_clearance_distance_rings.stl \
     fab/print_nema_motor_stand.stl \
     fab/motor_coupler.stl fab/print_motor_bearing_parts.stl \
     fab/laser_cut_mount_panel.dxf fab/laser_cut_knife_slider.dxf

ALL_IMAGES=img/machine-render.png \
           img/laser_cut_knife_slider.png img/laser_cut_mount_panel.png

all: $(ALL_TARGETS)

%.stl: %.scad
	openscad -q -o $@ $<

%.dxf: %.scad
	openscad -q -o $@ $<

update-images: $(ALL_IMAGES);

fab/%.scad : band-cutter-machine.scad
	mkdir -p fab
	echo "use <../band-cutter-machine.scad>; $*();" > $@

img/machine-render.png: fab/full_assembly.scad
	openscad -q -o$@-tmp.png --imgsize=4096,4096 \
             --camera=39,23,14,70,0,306,475 \
             --colorscheme=Nature $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmscale 0.25 | pnmtopng > $@
	rm -f $@-tmp.png

img/laser_cut_%.png: fab/laser_cut_%.scad
	openscad -q --projection=o --camera=0,0,0,0,0,0,0 --viewall \
	--imgsize=1024,1024 --colorscheme=Nature \
	-o $@-tmp.png $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmtopng > $@
	rm -f $@-tmp.png
