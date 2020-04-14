
# Hot Knife cutting machine for synthetic button-hole bands

*Work in Progress*

Here at [MakerNexus], we're now producing the face-shield parts via
injection-molding, so now one bottleneck is to cut enough elastic bands.

A Device to cut button-hole elastic, needed for the
[Covid-19 face shields][FaceShields].

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
is changed, a machine up to 5 bands in parallel can can fit on a Prusa MK3.
Change the value, type `make`, go in the fab/ directory.
Open `band-cutter-machine.3mf` with prusa-slicer and reload with `F5`.

 two bands                          | five bands
------------------------------------|------------------------------------
![](img/two-band-machine-slice.png) | ![](img/five-band-machine-slice.png)

![](img/machine-render.png)

### License

This is shared with the Creative Commons Attribution-ShareAlike [CC-BY-SA]
license.

[MakerNexus]: https://makernexus.com/
[FaceShields]: https://www.covidshieldnexus.org/
[CC-BY-SA]: https://creativecommons.org/licenses/by-sa/4.0/