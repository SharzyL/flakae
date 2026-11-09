{
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
      name = "ts_pnpm_playground";
      makePkg =
        { lib
        , stdenv
        , nodejs
        , pnpm_12
        , fetchPnpmDeps
        , pnpmConfigHook
        , pnpmBuildHook
        , writeShellScript
        }:

        stdenv.mkDerivation (finalAttrs: {
          pname = name;
          version = "0.1";

          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };

          pnpmDeps = fetchPnpmDeps {
            inherit (finalAttrs) pname version src;
            pnpm = pnpm_12;
            fetcherVersion = 4;
            hash = "sha256-RtbC1hf9SLbmkUTyEy3yr/T6dkVIRfm0iVyaBq2T2Hk=";
          };

          installPhase =
            let
              script = writeShellScript name ''
                ${nodejs}/bin/node $0/../../share/index.js
              '';
            in
            ''
              runHook preInstall
              mkdir -p $out/{share,bin}
              cp dist/index.js $out/share/
              cp ${script} $out/bin/${name}
              runHook postInstall
            '';

          nativeBuildInputs = [
            nodejs
            pnpm_12
            pnpmConfigHook
            pnpmBuildHook # runs `pnpm run build`
          ];

          meta.mainProgram = name;
        })
      ;

      shellOverride = pkgs: oldAttrs: { };
      overlay = final: _: {
        ${name} = final.callPackage makePkg { };
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
          programs.nixpkgs-fmt.enable = true;
          programs.biome = {
            enable = true;
            settings = builtins.fromJSON (builtins.readFile ./biome.json);
            # treefmt-nix falls back to the 2.1.2 schema for unknown biome versions,
            # update the hash when nixpkgs bumps biome
            validate.schema = pkgs.fetchurl {
              url = "https://biomejs.dev/schemas/${pkgs.biome.version}/schema.json";
              hash = "sha256-Z2/XiQKRUc7xnI4FSe9HhhyqD+/llHZsSPpuj+8C4GA=";
            };
          };
        };
      };
    };
}

