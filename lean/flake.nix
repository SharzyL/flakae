{
  description = "lean playground";

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

          defaultPackage = pkgs.stdenv.mkDerivation {
            name = "lean";
            src = with pkgs.lib.fileset; toSource {
              root = ./.;
              fileset = fileFilter (file: file.name != "flake.nix") ./.;
            };

            buildInputs = with pkgs; [
              lean4
            ];

           # just check, nothing built
            buildPhase = ''
              runHook preBuild
              lean ./src/Hello.lean
              mkdir -p $out
              runHook postBuild
            '';
          };

          devShell = defaultPackage.overrideAttrs (_: { });
        }
      )
    // {
      inherit inputs; # for easier introspection via nix repl
    };
}
