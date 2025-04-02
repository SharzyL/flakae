{
  description = "rust playground";

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

          defaultPackage = pkgs.rustPlatform.buildRustPackage {
            name = "rust_ground";
            src = with pkgs.lib.fileset; toSource {
              root = ./.;
              fileset = fileFilter (file: file.name != "flake.nix") ./.;
            };
            useFetchCargoVendor = true;
            cargoHash = "sha256-b/uKJ7y7/EqnrBwFF2t7b4wUwdmnt70kS+O9+wRKESI=";
          };

          devShell = defaultPackage.overrideAttrs (_: { });
        }
      )
    // {
      inherit inputs; # for easier introspection via nix repl
    };
}
