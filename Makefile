ALL_TARGETS=fab/mount_panel.stl \
     fab/wheel_stack.stl fab/support_enforder.stl \
     fab/print_wheel_idler.stl fab/print_infeed_weight_idler.stl \
     fab/infeed_fancy_tray.stl fab/print_outfeed.stl \
     fab/print_stack_spacer.stl \
     fab/print_sidewall_clearance_distance_rings.stl \
     fab/print_nema_motor_stand.stl \
     fab/motor_coupler.stl fab/print_motor_bearing_parts.stl \
     fab/laser_cut_mount_panel.dxf fab/laser_cut_knife_slider.dxf

all: $(ALL_TARGETS)

%.stl: %.scad
	openscad -o $@ $<

%.dxf: %.scad
	openscad -o $@ $<

fab/%.scad : band-cutter-machine.scad
	mkdir -p fab
	echo "use <../band-cutter-machine.scad>; $*();" > $@

img/machine-render.png: fab/full_assembly.scad
	openscad -o$@-tmp.png --imgsize=4096,4096 \
             --camera=39,23,14,70,0,306,475 \
             --colorscheme=Nature $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmscale 0.25 | pnmtopng > $@
	rm -f $@-tmp.png
