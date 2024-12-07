# Number of bands that the machine shall cut. More bands make the machine wider.
# With the default 3mf file, this can be scaled up to 5; even more
# is possible if the parts are divided into multiple consecutive prints.
BAND_STACK=2

# Call to openscad using fast Manifold backend and defining some global settings
# Note: needs to have https://github.com/openscad/openscad/pull/5473 applied
FN=196
OPENSCAD=openscad --backend Manifold -D'$$fn=$(FN)' -Dstack=$(BAND_STACK)

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

# There are 5 cycles shown, each probably should be > 7 seconds
# For 60fps, that would be at least 2100 frames.
# (for quick checks, set to much smaller value  as rendering takes a while)
ANIM_FRAME_COUNT=2100

# Utilized CPU cores in animation shardin
CPU_CORES := 8

all: all-stl all-dxf

all-stl: $(ALL_TARGETS_STL)
all-dxf: $(ALL_TARGETS_DXF)
update-images: $(ALL_IMAGES);

%.stl: %.scad
	$(OPENSCAD) -q -o $@ $<

%.dxf: %.scad
	$(OPENSCAD) -q -o $@ $<

fab/%.scad : band-cutter-machine.scad
	@mkdir -p fab
	echo "use <../band-cutter-machine.scad>; $*();" > $@

img/machine-render.png: fab/full_assembly.scad
	$(OPENSCAD) -q -o$@-tmp.png --imgsize=4096,4096 \
             --camera=39,23,14,70,0,306,475 \
             --colorscheme=Nature $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmscale 0.25 | pnmtopng > $@
	rm -f $@-tmp.png

img/laser_cut_%.png: fab/laser_cut_%.scad
	$(OPENSCAD) -q  \
             --projection=o --camera=0,0,0,0,0,0,0 --viewall \
	     --imgsize=4096,4096 --colorscheme=Nature \
	     -o $@-tmp.png $< \
         && cat $@-tmp.png | pngtopnm | pnmcrop | pnmtopng > $@
	rm -f $@-tmp.png

# Create PNG or POV animation frames.
anim/frame00000.%: band-cutter-machine.scad
	mkdir -p anim  # TODO: possible to tell openscad output-dir without cd ?
	cd anim ; for shard in `seq 1 $(CPU_CORES)`; do \
           $(OPENSCAD) --animate_sharding=$$shard/$(CPU_CORES) \
            --animate $(ANIM_FRAME_COUNT) \
            --imgsize=1920,1080 --colorscheme=Starnight --export-format=$* -q \
            ../$< & \
	done; wait

scad-anim.mp4: anim/frame00000.png   #... and more, triggered by the same rule
	ffmpeg -framerate 60 -y -i anim/frame%05d.png $@

clean:
	rm -f $(ALL_TARGETS_STL) $(ALL_TARGETS_DXF) anim/frame*
