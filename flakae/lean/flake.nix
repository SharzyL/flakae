{
  description = "lean playground";

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
      name = "lean_playground";
      makePkg = { lib, stdenv, lean4 }:
        stdenv.mkDerivation {
          inherit name;
          buildInputs = [
            lean4
          ];
          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };
          # just check, nothing built
          buildPhase = ''
            runHook preBuild
            lean ./src/Hello.lean
            mkdir -p $out
            runHook postBuild
          '';
        };
      overlay = final: _: { ${name} = final.callPackage makePkg { }; };

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

        devShells.default = config.packages.default;

        treefmt = {
          programs.nixpkgs-fmt.enable = true;
        };
      };
    };
}
