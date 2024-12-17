{
  description = "Openstarbound development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self , nixpkgs ,... }@inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
    };
    packages = self.packages.${system};
  in {
    packages.${system} = {
        fetchFromSteamWorkshop = pkgs.callPackage ./nix/fetchFromSteamWorkshop { };
        fetchStarboundMod = pkgs.callPackage ./nix/fetchStarboundMod.nix {
            inherit (packages) fetchFromSteamWorkshop;
        };

        openstarbound-raw = pkgs.callPackage ./nix/openstarbound-raw.nix { };
        openstarbound-app = pkgs.callPackage ./nix/openstarbound-app.nix {
            inherit (packages) openstarbound-raw;
        };
        openstarbound = pkgs.callPackage ./nix/openstarbound.nix {
            inherit (packages) openstarbound-raw;
        };
        default = packages.openstarbound;
        # default = packages.openstarbound-app;
    };

    apps.${system}.default = {
        type = "app";
        program = pkgs.lib.getExe packages.openstarbound-app;
    };
  };
}
