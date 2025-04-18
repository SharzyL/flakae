{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cpp_cmake.url = ./cpp_cmake;
    cuda_cmake.url = ./cuda_cmake;
    cpp_meson.url = ./cpp_meson;
    lean.url = ./lean;
    python_pdm.url = ./python_pdm;
    rust.url = ./rust;
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, ... }@inputs:
    let
      subflake_names = with nixpkgs.lib; filter
        (n: pathExists ./${n}/flake.nix)
        (attrNames inputs);
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            programs.clang-format.enable = true;
            programs.nixpkgs-fmt.enable = true;
          };

          subflake_pkgs = nixpkgs.lib.genAttrs
            subflake_names
            (subflake: inputs.${subflake}.packages.${system}.default);
        in
        {
          packages = {
            default = pkgs.linkFarm "flakae" subflake_pkgs;
          } // subflake_pkgs;
          formatter = treefmtEval.config.build.wrapper;
          checks.formatting = treefmtEval.config.build.check self;

        }) // {
      inherit inputs;
      templates = nixpkgs.lib.genAttrs subflake_names
        (name: {
          path = ./${name};
          description = "Template ${name}";
        });
    };

}
