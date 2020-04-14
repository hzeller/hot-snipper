
all: fab/mount_panel.stl \
     fab/wheel_stack.stl fab/support_enforder.stl \
     fab/print_stack_spacer.stl fab/print_wheel_idler.stl \
     fab/infeed_fancy_tray.stl fab/print_outfeed.stl

%.stl: %.scad
	openscad -o $@ $<

fab/%.scad : band-cutter-machine.scad
	mkdir -p fab
	echo "use <../band-cutter-machine.scad>; $*();" > $@
