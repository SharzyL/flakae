{
  description = "cpp cmake playground with cxx20 modules";

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
      name = "cpp_cmake_modules_playground";

      # see discussion from https://github.com/llvm/llvm-project/issues/121709
      makePkg = { lib, stdenv, cmake, ninja, spdlog, fmt, clang-tools, libcxx, catch2_3 }:
        let
          fmt_libcxx = fmt.override { inherit stdenv; };
          spdlog_libcxx = spdlog.override {
            inherit stdenv;
            fmt = fmt_libcxx;
            catch2_3 = catch2_3.override {
              inherit stdenv;
            };
          };
        in
        stdenv.mkDerivation {
          pname = name;
          version = "0.1.0";
          strictDeps = true;

          nativeBuildInputs = [
            cmake
            ninja
            clang-tools
          ];

          buildInputs =
            if stdenv.cc.libcxx != null then [
              spdlog_libcxx
              fmt_libcxx
            ] else [
              spdlog
              fmt
            ];

          # https://github.com/llvm/llvm-project/issues/121709
          hardeningDisable = [ "fortify" ];

          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };

          env.NIX_CFLAGS_COMPILE = toString [
            # https://github.com/llvm/llvm-project/issues/120215
            # to find the `libc++.modules.json`, clang driver searches for libc++.a
            "-B${lib.getLib stdenv.cc.libcxx}/lib"

            "-isystem ${lib.getDev stdenv.cc.libcxx}/include/c++/v1" # for `__config` and other headers
          ];

          meta.mainProgram = name;
        };

      shellOverride = pkgs: oldAttrs: {
        name = "${name}-dev-shell";
        version = null;
        src = null;

        # https://github.com/NixOS/nixpkgs/issues/214945
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ (with pkgs; [
          clang-tools
        ]);

        # make ninja output colorful
        shellHook = ''
          export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -fdiagnostics-color=always"
        '';
      };

      overlay = final: prev: {
        ${name} = final.callPackage makePkg {
          # we must use libcxxStdenv from llvmPackages for darwin,
          # otherwise libcxx shipped by Apple is used, which has no modules support
          stdenv = final.llvmPackages_latest.libcxxStdenv;
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
