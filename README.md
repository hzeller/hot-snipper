
# Hot Knife cutting machine for synthetic button-hole bands

*Work in Progress*

A Device to cut button-hole elastic, needed for the Covid-19 headbands.

Here at [MakerNexus], we're now producing the face-shield parts via
injection-molding, so now one bottleneck is to cut enough elastic bands.

This machine is for that, a hot knife (really at this point: hot wire) cutter
that allows to cut multiple parallel bands at once.

Most items can be entirely 3D printed. The provided fab/band-cutter-machine.3mf
file contains a print layout that provides all the parts needed to print a
machine that can cut two bands in parallel.

If the `stack` parameter in the [SCAD file](./band-cutter-machine.scad)
is changed, a machine up to 5 bands in parallel can can fit on a Prusa MK3.
Just type `make`, go in the fab/ directory and open `band-cutter-machine.3mf`
with prusa-slicer and reload with `F5`

 two bands                          | five bands
------------------------------------|------------------------------------
![](img/two-band-machine-slice.png) | ![](img/five-band-machine-slice.png)

![](img/machine-render.png)

[MakerNexus]: https://makernexus.com/