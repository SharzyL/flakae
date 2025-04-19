{
  description = "A collection of Nix flakes";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cpp_cmake.url = ./cpp_cmake;
    cpp_cmake_lib.url = ./cpp_cmake_lib;
    cuda_cmake.url = ./cuda_cmake;
    cpp_meson.url = ./cpp_meson;
    lean.url = ./lean;
    python_pdm.url = ./python_pdm;
    rust.url = ./rust;
  };

  outputs = { flake-parts, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;
      subflake_names = lib.filter
        (n: lib.pathExists ./${n}/flake.nix)
        (lib.attrNames (builtins.readDir ./.));

      subflake_pkg_names = map (n: "${n}_playground") subflake_names;

      overlay = lib.composeManyExtensions (map
        (subflake: inputs.${subflake}.overlays.default)
        subflake_names
      );

    in
    # flake-parts boilerplate
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = lib.systems.flakeExposed;
      perSystem = { system, pkgs, ... }:
        let
          subflake_pkgs = lib.genAttrs subflake_pkg_names (n: pkgs.${n});
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ overlay ];
            config.allowUnfree = true;
          };

          legacyPackages = pkgs;
          packages = {
            default = pkgs.linkFarm "flakae" subflake_pkgs;
          } // subflake_pkgs;

          checks = import ./tests pkgs;
        };

      flake.overlays.default = overlay;

      flake = {
        templates = lib.genAttrs subflake_names
          (name: {
            path = ./${name};
            description = "Template ${name}";
          });
      };
    };
}
