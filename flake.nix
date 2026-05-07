{
  description = "A collection of Nix flakes";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cpp_cmake.url = ./flakae/cpp_cmake;
    cpp_cmake_lib.url = ./flakae/cpp_cmake_lib;
    cpp_cmake_modules.url = ./flakae/cpp_cmake_modules;
    cuda_cmake.url = ./flakae/cuda_cmake;
    cpp_meson.url = ./flakae/cpp_meson;
    lean.url = ./flakae/lean;
    python_uv.url = ./flakae/python_uv;
    rust.url = ./flakae/rust;
    typst.url = ./flakae/typst;
    ts_yarn.url = ./flakae/ts_yarn;
    adhoc.url = ./flakae/adhoc;
  };

  outputs = { flake-parts, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;
      subflake_names = lib.attrNames (builtins.readDir ./flakae);

      overlay = lib.composeManyExtensions (map
        (subflake: inputs.${subflake}.overlays.default)
        subflake_names
      );

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = lib.systems.flakeExposed;
      perSystem = { system, pkgs, ... }:
        let
          subflake_pkgs = lib.genAttrs subflake_names (n:
            let
              pkg_name = with builtins; head (filter
                (n: n != "default")
                (attrNames (inputs.${n}.packages.aarch64-linux)));
            in
            pkgs.${pkg_name}
          );
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ overlay ];
            config.allowUnfree = true;
          };

          legacyPackages = pkgs;
          packages = subflake_pkgs;

          checks = removeAttrs
            (pkgs.callPackage ./check.nix {
              inherit subflake_pkgs;
            }) [ "overrideAttrs" "overrideDerivation" "override" ];
        };

      flake.overlays.default = overlay;

      flake = {
        templates = lib.genAttrs subflake_names
          (name: {
            path = ./flakae/${name};
            description = "Template ${name}";
          });
      };
    };
}
