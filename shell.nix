{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs;
    [
      openscad-unstable
      openscad-lsp

      # CAM
      prusa-slicer
      netpbm  # image render
      ffmpeg
      povray

      # For performance debugging
      #linuxKernel.packages.linux_6_6.perf
      #pprof
      #perf_data_converter
    ];
}
