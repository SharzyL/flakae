{
  description = "cpp cmake playground";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }@inputs:
    let
      name = "cpp_cmake_playground";
      makePkg = { lib, stdenv, cmake, ninja, spdlog, fmt }:
        stdenv.mkDerivation {
          inherit name;
          nativeBuildInputs = [ cmake ninja ];
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
        };
      overlay = final: _: { ${name} = final.callPackage makePkg { }; };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
          pkg = pkgs.${name};

          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            programs.clang-format.enable = true;
            programs.nixpkgs-fmt.enable = true;
          };
        in
        {
          devShells.default = pkg.overrideAttrs (oldAttrs: {
            # https://github.com/NixOS/nixpkgs/issues/214945
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ (with pkgs; [
              clang-tools
            ]);

            # make ninja output colorful
            shellHook = ''
              export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -fdiagnostics-color=always"
            '';
          });

          legacyPackages = pkgs;
          packages.default = pkg;
          formatter = treefmtEval.config.build.wrapper;
          checks.formatting = treefmtEval.config.build.check self;
        }
      )
    // {
      inherit inputs; # for easier introspection via nix repl
      overlays.default = overlay;
    };
}
