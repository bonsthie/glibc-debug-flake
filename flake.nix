{
  description = "A Nix Flake that replaces the system glibc with a prebuilt custom version";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: 
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

    glibcTarball = pkgs.fetchurl {
      url = "https://send.kanel.ovh/downloadFile?id=Xor3WQITqjZSDRz";
      sha256 = "10bjcflifcvs2k3983rzqsg4r54lh9g2c1m8xwcxb80k16cwks7k";
    };

    customGlibc = pkgs.stdenv.mkDerivation {
      pname = "glibc-custom";
      version = "2.39.9";

      src = glibcTarball;

      dontConfigure = true;
      dontBuild = true;

      unpackPhase = ''
        mkdir source
        tar -xzf $src -C source --strip-components=1
      '';

      installPhase = ''
        mkdir -p $out/lib $out/bin
        cp -r source/lib/* $out/lib/
        cp -r source/bin/* $out/bin/ || true  # Ignore if no bin directory exists
      '';

      meta = {
        description = "Prebuilt custom glibc";
        license = pkgs.lib.licenses.lgpl2;
      };
    };

  in {
    packages.x86_64-linux = {
      glibc = customGlibc;
    };

    overlays.default = final: prev: {
      glibc = customGlibc;
    };

    nixosModules.replaceGlibc = { config, lib, pkgs, ... }: {
      environment.systemPackages = [ customGlibc ];
      environment.variables.LD_LIBRARY_PATH = "${customGlibc}/lib";
      system.replaceRuntimeDependencies = [
        {
          original = pkgs.glibc;
          replacement = customGlibc;
        }
      ];
    };
  };
}
