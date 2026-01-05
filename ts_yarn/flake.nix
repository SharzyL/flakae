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
      name = "yarn_playground";
      makePkg =
        { lib
        , stdenv
        , nodejs
        , yarn-berry
        , writeShellScript
        }:

        stdenv.mkDerivation (finalAttrs: {
          pname = "yarn_playground";
          version = "0.1";

          src = with lib.fileset; toSource {
            root = ./.;
            fileset = fileFilter
              (file: ! (lib.elem file.name [ "flake.nix" "flake.lock" ]))
              ./.;
          };

          offlineCache = yarn-berry.fetchYarnBerryDeps {
            inherit (finalAttrs) src missingHashes;
            hash = "sha256-3IbStliCI03O8J76aTScdDb7UxW0oZaLMOsj/IDlWM4=";
          };

          buildPhase = ''
            runHook preBuild
            yarn build
            runHook postBuild
          '';

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

          # In case native deps are used, generated the file by running
          # nix run nixpkgs#yarn-berry.yarn-berry-fetcher missing-hashes yarn.lock > missing-hashes.json
          missingHashes = ./missing-hashes.json;

          nativeBuildInputs = [
            yarn-berry
            yarn-berry.yarnBerryConfigHook
            nodejs
          ];
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
          };
        };
      };
    };
}

