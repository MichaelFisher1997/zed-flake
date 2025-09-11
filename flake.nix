{
  description = "Zed Editor - Latest version from source using Zed's official flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zed.url = "github:zed-industries/zed";
    zed.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, zed, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        
        # Use Zed's own build from their flake
        zed-package = zed.packages.${system}.default;
      in
      {
        packages.default = zed-package;
        
        apps.zed = {
          type = "app";
          program = "${zed-package}/bin/zed";
        };
        
        apps.default = self.apps.${system}.zed;
        
        # Also provide a development shell using Zed's shell
        devShells.default = zed.devShells.${system}.default;
        
        # Expose Zed's overlay for convenience
        overlays.default = zed.overlays.default;
      });
}