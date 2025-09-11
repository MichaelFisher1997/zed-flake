{
  description = "Zed Editor - High-performance, multiplayer code editor from source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, crane, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config.allowUnfree = true;
        };

        # Rust toolchain from Zed's repository
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        # Build Zed from source using rustPlatform
        zed-package = pkgs.rustPlatform.buildRustPackage rec {
          pname = "zed";
          version = "0.203.4";
          
          src = pkgs.fetchFromGitHub {
            owner = "zed-industries";
            repo = "zed";
            rev = "v${version}";
            hash = "sha256-fDjKBZvXla6K0OLs40igxSe1Xn+uMD81F0PbIur8Y7o=";
          };
          
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          
          buildInputs = [
            pkgs.alsa-lib
            pkgs.curl
            pkgs.fontconfig
            pkgs.freetype
            pkgs.libgit2
            pkgs.libglvnd
            pkgs.libxkbcommon
            pkgs.nodejs_22
            pkgs.openssl
            pkgs.protobuf
            pkgs.sqlite
            pkgs.vulkan-loader
            pkgs.wayland
            pkgs.xorg.libX11
            pkgs.xorg.libXcursor
            pkgs.xorg.libXi
            pkgs.xorg.libXrandr
            pkgs.xorg.libxcb
            pkgs.zlib
            pkgs.zstd
          ];
          
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.makeWrapper
            pkgs.pkg-config
            pkgs.perl
            pkgs.protobuf
          ];
          
          buildPhase = ''
            runHook preBuild
            cargo build --release --package zed --package cli
            runHook postBuild
          '';
          
          installPhase = ''
            runHook preInstall
            
            # Install the binaries
            mkdir -p $out/bin
            cp target/release/zed $out/bin/
            
            # Install desktop file and icons
            mkdir -p $out/share/applications
            cp assets/zed.desktop $out/share/applications/ || true
            
            mkdir -p $out/share/icons/hicolor/512x512/apps
            mkdir -p $out/share/icons/hicolor/1024x1024/apps
            cp assets/zed-512.png $out/share/icons/hicolor/512x512/apps/zed.png || true
            cp assets/zed-1024.png $out/share/icons/hicolor/1024x1024/apps/zed.png || true
            
            # Wrap the binary
            wrapProgram $out/bin/zed \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
                pkgs.stdenv.cc.cc.lib
                pkgs.xorg.libX11
                pkgs.xorg.libXcursor
                pkgs.xorg.libXi
                pkgs.xorg.libXrandr
                pkgs.xorg.libxcb
                pkgs.wayland
                pkgs.libxkbcommon
                pkgs.vulkan-loader
              ]} \
              --set XDG_RUNTIME_DIR "/run/user/$(id -u)" \
              --set TMPDIR "/run/user/$(id -u)"
              
            runHook postInstall
          '';
          
          meta = with pkgs.lib; {
            description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
            homepage = "https://zed.dev";
            license = licenses.gpl3Only;
            platforms = platforms.linux;
            maintainers = [ maintainers.micqdf ];
          };
        };
      in
      {
        packages.default = zed-package;
        
        apps.zed = {
          type = "app";
          program = "${zed-package}/bin/zed";
        };
        
        apps.default = self.apps.${system}.zed;
        
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rustToolchain
            pkgs.cargo
            pkgs.rustc
            pkgs.cmake
            pkgs.pkg-config
            pkgs.openssl
            pkgs.fontconfig
            pkgs.nodejs_22
            pkgs.protobuf
          ];
        };
      });
}