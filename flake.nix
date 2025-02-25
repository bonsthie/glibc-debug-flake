{
  description = "glibc with custom CFLAGS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            glibc = prev.glibc.overrideAttrs (oldAttrs: rec {
              CFLAGS = "-Wno-error -O1 -g3";
            });
          })
        ];
      };
    in {
      # This defines the default package attribute
      packages.${system}.default = pkgs.glibc;

      # This defines a devShell that includes glibc as a build input
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.glibc ];
      };
    };
}
