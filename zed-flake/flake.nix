{
  description = "Zed Editor - High-performance, multiplayer code editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zed-src = {
      url = "github:zed-industries/zed";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
    zed-src,
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

        craneLib = crane.mkLib pkgs;
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile "${zed-src}/rust-toolchain.toml";

        zed = pkgs.callPackage "${zed-src}/nix/build.nix" {
          inherit crane;
          inherit rustToolchain;
          withGLES = false;
          profile = "release";
        };

        # Alternative configurations
        zedGLES = pkgs.callPackage "${zed-src}/nix/build.nix" {
          inherit crane;
          inherit rustToolchain;
          withGLES = true;
          profile = "release";
        };

        zedDebug = pkgs.callPackage "${zed-src}/nix/build.nix" {
          inherit crane;
          inherit rustToolchain;
          withGLES = false;
          profile = "dev";
        };
      in {
        packages = {
          default = zed;
          inherit zed zedGLES zedDebug;
        };

        devShells = {
          default = pkgs.callPackage "${zed-src}/nix/shell.nix" {
            zed-editor = zed;
          };
          gles = pkgs.callPackage "${zed-src}/nix/shell.nix" {
            zed-editor = zedGLES;
          };
          debug = pkgs.callPackage "${zed-src}/nix/shell.nix" {
            zed-editor = zedDebug;
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