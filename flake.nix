{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
    cpp_cmake.url = "path:./cpp_cmake";
    cuda_cmake.url = "path:./cuda_cmake";
    lean.url = "path:./lean";
    python_pdm.url = "path:./python_pdm";
    rust.url = "path:./rust";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      subflake_names = with nixpkgs.lib; filter
        (n: pathExists ./${n}/flake.nix)
        (attrNames inputs);
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages = nixpkgs.lib.genAttrs
          subflake_names
          (subflake: inputs.${subflake}.defaultPackage.${system});

        defaultPackage = pkgs.symlinkJoin
          {
            name = "flakae";
            paths = builtins.attrValues packages;
          };
      });

}
