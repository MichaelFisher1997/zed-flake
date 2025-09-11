{
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
    zed-flake = {
      url = "path:./zed-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.crane.follows = "crane";
      inputs.zed-src.follows = "zed-src";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane, zed-src, zed-flake }:
    flake-utils.lib.eachDefaultSystem (system: {
      # Re-export the zed-flake outputs
      inherit (zed-flake) packages devShells apps formatter overlays;
    });
}