{
  description = "Zed Editor - High-performance, multiplayer code editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "openssl-1.1.1w"
            ];
          };
        };

        # Use our custom build
        zed = pkgs.callPackage ./default.nix {
          withGLES = false;
          profile = "release";
        };

        zedGLES = pkgs.callPackage ./default.nix {
          withGLES = true;
          profile = "release";
        };

        zedDebug = pkgs.callPackage ./default.nix {
          withGLES = false;
          profile = "dev";
        };
      in {
        packages = {
          default = zed;
          inherit zed zedGLES zedDebug;
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              zed
              pkgs.rust-analyzer
              pkgs.cargo
              pkgs.rustc
              pkgs.nodejs
              pkgs.protobuf
              pkgs.pkg-config
              pkgs.openssl
              pkgs.fontconfig
              pkgs.freetype
              pkgs.cmake
              pkgs.makeWrapper
            ];
          };
        };

        apps = {
          zed = {
            type = "app";
            program = "${zed}/bin/zed";
          };
          zed-gles = {
            type = "app";
            program = "${zedGLES}/bin/zed";
          };
          zed-debug = {
            type = "app";
            program = "${zedDebug}/bin/zed";
          };
        };

        formatter = pkgs.alejandra;

        overlays.default = final: prev: {
          zed-editor = zed;
          zed-editor-gles = zedGLES;
          zed-editor-debug = zedDebug;
        };
      }
    );
}