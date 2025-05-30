{
  description = "typst document";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, typix, ... }@inputs:
    let
      name = "typst_playground";
      makePkg = { lib, stdenv, typst, cascadia-code }:
        typix.lib.${stdenv.system}.mkTypstDerivation {
          name = name + ".pdf";
          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./${name}.typ
              ./templates
              ./assets
            ];
          };

          buildPhaseTypstCommand = ''
            typst compile ${name}.typ -f pdf "$out"
          '';

          unstable_typstPackages = [
            {
              name = "touying";
              version = "0.6.1";
              hash = "sha256-bTDc32MU4GPbUbW5p4cRSxsl9ODR6qXinvQGeHu2psU=";
            }
            {
              name = "codly";
              version = "1.3.0";
              hash = "sha256-WcqvySmSYpWW+TmZT7TgPFtbEHA+bP5ggKPll0B8fHk=";
            }
          ];

          fontPaths = [
            cascadia-code
            # TODO: also add avenir
          ];
        };
      shellOverride = pkgs: oldAttrs: {
        name = "${name}.pdf-dev-shell";
        version = null;

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ (with pkgs; [
          typstyle
        ]);
      };

      overlay = final: prev: {
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
          programs.typstyle.enable = true;
          programs.nixpkgs-fmt.enable = true;
        };
      };
    };
}
