{
  description = "A nix shell for zmk";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    keymap-drawer = {
      url = "github:caksoylar/keymap-drawer";
      flake = false;
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
      ];

      perSystem = {
        pkgs,
        config,
        system,
        ...
      }: let
        inherit (inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) defaultPoetryOverrides mkPoetryApplication;

        keymap-drawer = mkPoetryApplication {
          projectDir = inputs.keymap-drawer;
          overrides =
            defaultPoetryOverrides.extend
            (self: super: {
              deptry =
                super.deptry.overridePythonAttrs
                (
                  old: {
                    buildInputs = (old.buildInputs or []) ++ [super.poetry];
                  }
                );
            });
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "zmk-keyboards";
          inputsFrom = [
            # config.boulder.devShell
            # config.zmk.devShell
          ];
          packages = with pkgs; [
            keymap-drawer
            # gen-keymap-img
            # nodePackages.serve
            # watch-keymap-drawer
            # config.zmk.matrix.corne-left.build
          ];
        };
      };
    };
}
