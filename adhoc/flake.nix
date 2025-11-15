{
  description = "adhoc playground";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    let
      name = "adhoc_playground";
      makePkg = { stdenv, yarn-berry }:
        stdenv.mkDerivation {
          pname = name;
          nativeBuildInputs = [
            # whatever deps
            yarn-berry
          ];
          version = "0.1.0";

          buildCommand = ''
            mkdir -p $out
          '';
        };

      shellOverride = pkgs: oldAttrs: { };
      overlay = final: _: {
        ${name} = final.callPackage makePkg { };
      };

    in
    # flake-parts boilerplate
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake.overlays.default = overlay;

      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      perSystem = { system, config, pkgs, ... }: {
        packages.default = config.legacyPackages.${name};
        packages.${name} = config.packages.default;
        legacyPackages = pkgs;

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        devShells.default = config.packages.default.overrideAttrs (shellOverride pkgs);

        treefmt = {
          programs.nixpkgs-fmt.enable = true;
        };
      };
    };
}
