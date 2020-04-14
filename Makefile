
all: fab/mount_panel.stl \
     fab/wheel_stack.stl fab/support_enforder.stl \
     fab/print_wheel_idler.stl fab/print_infeed_weight_idler.stl \
     fab/infeed_fancy_tray.stl fab/print_outfeed.stl \
     fab/print_stack_spacer.stl \
     fab/mount_panel_2d.dxf

%.stl: %.scad
	openscad -o $@ $<

%.dxf: %.scad
	openscad -o $@ $<

fab/%.scad : band-cutter-machine.scad
	mkdir -p fab
	echo "use <../band-cutter-machine.scad>; $*();" > $@

img/machine-render.png: fab/full_assembly.scad
	openscad -o$@-tmp.png --imgsize=4096,4096 \
             --camera=15.51,10.88,19.48,76,0,257,374 \
             --colorscheme=Nature $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmscale 0.25 | pnmtopng > $@
	rm -f $@-tmp.png