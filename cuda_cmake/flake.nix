{
  description = "cuda cmake playground";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "flake-parts";
    treefmt-nix = {
      url = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    let
      name = "cuda_cmake_playground";
      makePkg = { lib, stdenv, cmake, ninja, cudaPackages, autoAddDriverRunpath }:
        stdenv.mkDerivation {
          pname = name;
          version = "0.1.0";

          nativeBuildInputs = [ cmake ninja ];
          buildInputs = [
            cudaPackages.cudatoolkit
            cudaPackages.cuda_cudart

            autoAddDriverRunpath
          ];

          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };
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
          export NIX_LDFLAGS="$NIX_LDFLAGS -rpath /run/opengl-driver/lib"
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/run/opengl-driver/lib:${pkgs.xorg.libXtst}/lib:${pkgs.systemd}/lib"
        '';
      };

      overlay = final: _:
        let
          cudaStdenv = final.gcc14Stdenv;
          mycudaPackages = final.cudaPackages_12_8;
        in
        {
          ${name} = final.callPackage makePkg {
            stdenv = cudaStdenv;
            cudaPackages = mycudaPackages;
          };
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
        packages."${name}" = config.packages.default;
        legacyPackages = pkgs;

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ overlay ];
          config.allowUnfree = true;
        };

        devShells.default = config.packages.default.overrideAttrs (shellOverride pkgs);

        treefmt = {
          programs.clang-format.enable = true;
          programs.nixpkgs-fmt.enable = true;
        };
      };
    };
}
