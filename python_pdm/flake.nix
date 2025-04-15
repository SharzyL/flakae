{
  description = "python pdm playground";

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
      name = "python_pdm_playground";
      makePkg = { lib, buildPythonPackage, pdm-backend, numpy }:
        buildPythonPackage {
          inherit name;
          pyproject = true;
          nativeBuildInputs = [ pdm-backend ];

          propagatedBuildInputs = [
            numpy
          ];

          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };
        };
      overlay = final: _: { ${name} = final.python3Packages.callPackage makePkg { }; };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
          pkg = pkgs.${name};

          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            programs.mypy.enable = true;
            programs.nixpkgs-fmt.enable = true;
          };
        in
        {
          devShells.default = pkg;
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
