{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs;
    [
      openscad-unstable
      openscad-lsp

      # CAM
      prusa-slicer  
      netpbm  # image render
    ];
}
