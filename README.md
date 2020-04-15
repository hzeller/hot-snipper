![](img/hot-snipper.png)

# Hot Knife cutting machine for synthetic button-hole bands

*Work in Progress*

Here at [MakerNexus], we're now producing the [Covid-19 effort][FaceShields]
face-shield parts via injection-molding, so now one bottleneck is to cut
enough elastic bands, which at this point happens entirely by hand.

This device helps to cut button-hole elastic.

It is specialized to work with the particular band we have in width
and button-hole distance; it cuts exactly the length we need (18 holes apart,
just between the holes). Changes in these specifications can easily be
adapted with the parametric CAD model.

This machine is for that, a hot knife (really at this point: hot wire) cutter
that allows to cut multiple parallel bands at once.

## Manufacturing
Most items can be entirely 3D printed. The provided fab/band-cutter-machine.3mf
file contains a print layout that provides all the parts needed to print a
machine that can cut two bands in parallel.

If the `stack` parameter in the [SCAD file](./band-cutter-machine.scad#L7)
is changed, a machine that can cut up to 5 bands in parallel can can fit on
a Prusa MK3 bed.
Change the value, type `make`, `cd fab/`.
Open `band-cutter-machine.3mf` with prusa-slicer and reload with `F5`. There
seems to be a bug in prusa-slicer which then slightly mis-aligns the cylinder
support enforcer around the main wheel; adjust that first before slicing.

 two bands                          | five bands
------------------------------------|------------------------------------
![](img/two-band-machine-slice.png) | ![](img/five-band-machine-slice.png)

The side-panels take a lot of time to print, so if there is a laser cutter
available, the Makefile will also generate `fab/mount_panel_2d.dxf` for
lasercutting the panel.

## Assembly

Parts fit together pretty straightforward, check out the rendering and
picture below.

As 'axles', I am using easy-to-get threaded rods, cut to length (whatever
is easy to get; 6mm or 1/4").
All of these should be held in place by retaining rings (I don't have any
right now, so this is why it is temporarily using nuts).

The center wheel drive: work in progress. Plan is to have a stepper motor
here, but maybe initially just a hand-crank.

Hot Knife: Work in progress. The slot in which it is sliding is already part
of the side-panel, but that might change.

 Render                     | Assembled
----------------------------|-----------------------
![](img/machine-render.png) | ![](img/assembled.jpg)


## Usage

Loading the band requires it to go around the lower idler, then around the
central wheel and emerging at the top.

In order to get it through the in-feed tray and under the lower idler, it
is possible to unlatch the infeed-tray and rotate so that this can be done
with the least amount of fiddling.

 Feeding with opened loading tray        | Closed back up
-----------------------------------------|----------------
![](img/loading-process.jpg)             | ![](img/loading-bay-closed.jpg)

Now, wrap around the button elastic half way around the big wheel, then
under the top idlers (that can be moved up manually. In this picture purple
and red) so that the elastics emerge at the front; we're now fully loaded:

![](img/front-view.jpg)

### License

This is shared with the Creative Commons Attribution-ShareAlike [CC-BY-SA]
license.

[MakerNexus]: https://makernexus.com/
[FaceShields]: https://www.covidshieldnexus.org/
[CC-BY-SA]: https://creativecommons.org/licenses/by-sa/4.0/