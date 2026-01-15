{
  description = "rust playground";

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
      name = "rust_playground";
      makePkg = { lib, rustPlatform, rustc, cargo, runCommand }:
        rustPlatform.buildRustPackage {
          inherit name;
          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };

          passthru.toolchain = runCommand "rust-toolchain" { } ''
            mkdir -p $out/{bin,lib}
            ln -s ${rustc}/bin/rustc $out/bin/
            ln -s ${cargo}/bin/cargo $out/bin/
            ln -s ${rustPlatform.rustLibSrc} $out/src
          '';

          cargoHash = "sha256-+SYzNqGgQr3TmK8qEN8EsNo1KOu0cT3UEB4tiAjk5As=";
          meta.mainProgram = name;
        };

      shellOverride = pkgs: oldAttrs: {
        name = "${name}-dev-shell";
        version = null;
        src = null;
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ (with pkgs; [
          clippy
        ]);
        shellHook = ''
          echo RUST_TOOLCHAIN: ${oldAttrs.passthru.toolchain}
        '';
      };

      overlay = final: _: { ${name} = final.callPackage makePkg { }; };

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
          programs.rustfmt.enable = true;
          programs.nixpkgs-fmt.enable = true;
        };
      };
    };
}
