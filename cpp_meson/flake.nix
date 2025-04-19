{
  description = "cpp meson playground";

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
      name = "cpp_meson_playground";
      makePkg = { lib, stdenv, meson, cmake, ninja, spdlog, fmt }:
        stdenv.mkDerivation {
          pname = name;
          version = "0.1.0";
          # we need cmake to help meson to find deps
          nativeBuildInputs = [ meson ninja cmake ];
          buildInputs = [
            spdlog
            fmt
          ];
          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };
          meta.mainProgram = name;
        };
      shellOverride = pkgs: oldAttrs: {
        name = "${name}-dev-shell";
        version = null;

        # https://github.com/NixOS/nixpkgs/issues/214945
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ (with pkgs; [
          clang-tools
        ]);

        # make ninja output colorful
        shellHook = ''
          export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -fdiagnostics-color=always"
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

        devShells.default = config.packages.default.overrideAttrs (shellOverride pkgs);

        treefmt = {
          programs.clang-format.enable = true;
          programs.nixpkgs-fmt.enable = true;
        };
      };
    };
}
