{
  description = "python pdm playground";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        rec {
          legacyPackages = pkgs;

          defaultPackage = pkgs.python3.pkgs.buildPythonPackage {
            name = "python_pdm";
            pyproject = true;
            nativeBuildInputs = with pkgs.python3.pkgs; [ pdm-backend ];

            propagatedBuildInputs = with pkgs.python3.pkgs; [
              numpy
            ];

            src = with pkgs.lib.fileset; toSource {
              root = ./.;
              fileset = fileFilter
                (
                  file: ! (pkgs.lib.elem file.name [ "flake.nix" "flake.lock" ])
                ) ./.;
            };
          };

          devShell = defaultPackage.overrideAttrs (oldAttrs: {
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.pdm ];
          });

        }
      )
    // {
      inherit inputs; # for easier introspection via nix repl
    };
}
