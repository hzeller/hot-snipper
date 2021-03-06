# Number of bands that the machine shall cut. More bands make the machine wider.
# With the default 3mf file, this can be scaled up to 5; even more
# is possible if the parts are divided into multiple consecutive prints.
BAND_STACK=2

ALL_TARGETS_STL=fab/mount_panel.stl \
     fab/wheel_stack.stl fab/support_enforder.stl \
     fab/print_wheel_idler.stl fab/print_infeed_weight_idler.stl \
     fab/infeed_fancy_tray.stl fab/print_outfeed.stl \
     fab/print_stack_spacer.stl \
     fab/print_sidewall_clearance_distance_rings.stl \
     fab/print_nema_motor_stand.stl \
     fab/motor_coupler.stl fab/print_motor_bearing_parts.stl

ALL_TARGETS_DXF=fab/laser_cut_mount_panel.dxf fab/laser_cut_knife_slider.dxf

ALL_IMAGES=img/machine-render.png \
           img/laser_cut_knife_slider.png img/laser_cut_mount_panel.png

all: all-stl all-dxf

all-stl: $(ALL_TARGETS_STL)
all-dxf: $(ALL_TARGETS_DXF)

%.stl: %.scad
	openscad -q -Dstack=$(BAND_STACK) -o $@ $<

%.dxf: %.scad
	openscad -q -Dstack=$(BAND_STACK) -o $@ $<

update-images: $(ALL_IMAGES);

fab/%.scad : band-cutter-machine.scad
	mkdir -p fab
	echo "use <../band-cutter-machine.scad>; $*();" > $@

img/machine-render.png: fab/full_assembly.scad
	openscad -q -Dstack=$(BAND_STACK) -o$@-tmp.png --imgsize=4096,4096 \
             --camera=39,23,14,70,0,306,475 \
             --colorscheme=Nature $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmscale 0.25 | pnmtopng > $@
	rm -f $@-tmp.png

img/laser_cut_%.png: fab/laser_cut_%.scad
	openscad -q -Dstack=$(BAND_STACK) \
             --projection=o --camera=0,0,0,0,0,0,0 --viewall \
	     --imgsize=1024,1024 --colorscheme=Nature \
	     -o $@-tmp.png $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmtopng > $@
	rm -f $@-tmp.png

# This assumes some animation with dump-pictures enabled in UI. Unfortuantely,
# there is no simple offline way yet to do that yet.
# There are 5 cycles shown, each probably should be > 7 seconds
# For 60fps, that would be at least 2100 frames.
cut-wheel.mp4: frame00000.png   #... and more
	ffmpeg -framerate 60 -y -i frame%05d.png $@
