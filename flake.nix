{
  description = "Zed Code Editor - Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Function to create Zed package for a specific channel and architecture
        makeZedPkg = { channel, arch, sha256 ? null }:
          let
            isStable = channel == "stable";
            baseUrl = "https://zed.dev/api/releases/${channel}/latest";
            tarballName = "zed-linux-${arch}.tar.gz";
            url = "${baseUrl}/${tarballName}";
            appName = if isStable then "zed.app" else "zed-preview.app";
            
            # Fetch the tarball to get the hash if not provided
            src = if sha256 != null 
              then pkgs.fetchurl { inherit url sha256; }
              else pkgs.fetchurl {
                  inherit url;
                  sha256 = pkgs.lib.fakeSha256;
                };
          in
          pkgs.stdenv.mkDerivation {
            pname = "zed";
            version = if isStable then "stable" else "preview";
            
            inherit src;
            
            nativeBuildInputs = with pkgs; [ 
              autoPatchelfHook 
              makeWrapper 
              installShellFiles
            ];
            
            buildInputs = with pkgs; [
              glibc
              stdenv.cc.cc
              zlib
              libgcc
              vulkan-loader
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr
              xorg.libxcb
              xorg.libXext
              xorg.libXinerama
              xorg.libXfixes
              xorg.libXrender
              libxkbcommon
              wayland
              wayland-protocols
              fontconfig
              freetype
              dbus
              openssl
              alsa-lib
              libGL
              libglvnd
            ];
            
            runtimeDependencies = with pkgs; [
              vulkan-loader
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr
              xorg.libxcb
              xorg.libXext
              xorg.libXinerama
              xorg.libXfixes
              xorg.libXrender
              libxkbcommon
              wayland
              wayland-protocols
              fontconfig
              freetype
              dbus
              openssl
              alsa-lib
              libGL
              libglvnd
            ];
            
            sourceRoot = ".";
            
            installPhase = ''
              runHook preInstall
              
              # Create directories
              mkdir -p $out/bin
              mkdir -p $out/share/applications
              mkdir -p $out/share/icons/hicolor/512x512/apps
              mkdir -p $out/libexec
              
              # Copy the main application
              cp -r ${appName} $out/zed.app
              
              # Create wrapper script for the binary
              makeWrapper $out/zed.app/bin/zed $out/bin/zed \
                --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath (with pkgs; [
                  vulkan-loader
                  xorg.libX11
                  xorg.libXcursor
                  xorg.libXi
                  xorg.libXrandr
                  xorg.libxcb
                  xorg.libXext
                  xorg.libXinerama
                  xorg.libXfixes
                  xorg.libXrender
                  libxkbcommon
                  wayland
                  wayland-protocols
                  fontconfig
                  freetype
                  dbus
                  openssl
                  alsa-lib
                  libGL
                  libglvnd
                  stdenv.cc.cc
                  glibc
                ])} \
                --set VK_ICD_FILENAMES "${pkgs.lib.makeSearchPath "etc/vulkan/icd.d" (with pkgs; [ vulkan-validation-layers mesa ])}"
              
              # Install desktop file
              cp $out/zed.app/share/applications/${if isStable then "zed.desktop" else "zed-preview.desktop"} $out/share/applications/dev.zed.Zed.desktop
              
              # Fix paths in desktop file
              substituteInPlace $out/share/applications/dev.zed.Zed.desktop \
                --replace "Icon=zed" "Icon=$out/share/icons/hicolor/512x512/apps/zed.png" \
                --replace "Exec=zed" "Exec=$out/libexec/zed-editor"
              
              # Install icon
              cp $out/zed.app/share/icons/hicolor/512x512/apps/zed.png $out/share/icons/hicolor/512x512/apps/
              
              # Create libexec wrapper for desktop file
              makeWrapper $out/zed.app/libexec/zed-editor $out/libexec/zed-editor \
                --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath (with pkgs; [
                  vulkan-loader
                  xorg.libX11
                  xorg.libXcursor
                  xorg.libXi
                  xorg.libXrandr
                  xorg.libxcb
                  xorg.libXext
                  xorg.libXinerama
                  xorg.libXfixes
                  xorg.libXrender
                  libxkbcommon
                  wayland
                  wayland-protocols
                  fontconfig
                  freetype
                  dbus
                  openssl
                  alsa-lib
                  libGL
                  libglvnd
                  stdenv.cc.cc
                  glibc
                ])} \
                --set VK_ICD_FILENAMES "${pkgs.lib.makeSearchPath "etc/vulkan/icd.d" (with pkgs; [ vulkan-validation-layers mesa ])}"
              
              # Install shell completions if available
              if [ -d "$out/zed.app/share/bash-completion/completions" ]; then
                installShellCompletion --bash --name zed $out/zed.app/share/bash-completion/completions/zed
              fi
              
              if [ -d "$out/zed.app/share/zsh/site-functions" ]; then
                installShellCompletion --zsh --name _zed $out/zed.app/share/zsh/site-functions/_zed
              fi
              
              if [ -d "$out/zed.app/share/fish/vendor_completions.d" ]; then
                installShellCompletion --fish --name zed.fish $out/zed.app/share/fish/vendor_completions.d/zed.fish
              fi
              
              runHook postInstall
            '';
            
            meta = with pkgs.lib; {
              description = "Zed Code Editor (${channel} channel)";
              longDescription = ''
                Zed is a high-performance, multiplayer code editor from the creators of Atom and Tree-sitter.
                This package provides the ${channel} release channel for Linux ${arch}.
              '';
              homepage = "https://zed.dev";
              downloadPage = "https://zed.dev/download";
              license = licenses.gpl3Plus;
              sourceProvenance = with sourceTypes; [ binaryNativeCode ];
              platforms = [ "x86_64-linux" "aarch64-linux" ];
              maintainers = with maintainers; [ ];
              mainProgram = "zed";
            };
          };
        
        # Architecture detection
        arch = if pkgs.stdenv.isx86_64 then "x86_64" 
               else if pkgs.stdenv.isAarch64 then "aarch64"
               else throw "Unsupported architecture: ${system}";
        
        # Package definitions with known hashes (these will need to be updated periodically)
        zed-stable = makeZedPkg {
          channel = "stable";
          inherit arch;
          sha256 = if arch == "x86_64" 
            then "sha256-jx35qQ4WK9sgkzEcGw9mqAktWz5tZ4R5mfiYQIvd5Fk="
            else "sha256-N9q/P+xz+zAdwOTQ1hx6AglRoDWKEV7UEVQfNFhKbvQ=";
        };
        
        zed-preview = makeZedPkg {
          channel = "preview";
          inherit arch;
          sha256 = if arch == "x86_64"
            then "sha256-iwPOtdzmSmByuoIomUcbA2+i2TAuYlnPPCNJs3TViQc="
            else "sha256-aGCRVc4q8K8PURGAic2dg23EvlaeCIilVKVIMhaNtVE=";
        };
        
        # Default package (stable)
        zed = zed-stable;
        
      in {
        packages = {
          default = zed;
          zed = zed;
          zed-stable = zed-stable;
          zed-preview = zed-preview;
        };
        
        apps = {
          zed = flake-utils.lib.mkApp {
            drv = zed;
          };
          zed-stable = flake-utils.lib.mkApp {
            drv = zed-stable;
          };
          zed-preview = flake-utils.lib.mkApp {
            drv = zed-preview;
          };
        };
        
        # Home Manager module
        homeManagerModules.default = { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.programs.zed;
          in {
            options.programs.zed = {
              enable = mkEnableOption "Zed Code Editor";
              package = mkOption {
                type = types.package;
                default = zed;
                description = "The Zed package to use.";
              };
              channel = mkOption {
                type = types.enum [ "stable" "preview" ];
                default = "stable";
                description = "Which Zed release channel to use.";
              };
            };
            
            config = mkIf cfg.enable {
              home.packages = [ cfg.package ];
              
              # Optional: Set up desktop integration
              xdg.dataFile."applications/dev.zed.Zed.desktop".source = 
                "${cfg.package}/share/applications/dev.zed.Zed.desktop";
              
              # Optional: Set up environment variables for better GPU support
              home.sessionVariables = {
                VK_ICD_FILENAMES = "${pkgs.lib.makeSearchPath "etc/vulkan/icd.d" (with pkgs; [ vulkan-validation-layers mesa ])}";
              };
            };
          };
        
        # NixOS module
        nixosModules.default = { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.programs.zed;
          in {
            options.programs.zed = {
              enable = mkEnableOption "Zed Code Editor";
              package = mkOption {
                type = types.package;
                default = zed;
                description = "The Zed package to use.";
              };
              channel = mkOption {
                type = types.enum [ "stable" "preview" ];
                default = "stable";
                description = "Which Zed release channel to use.";
              };
            };
            
            config = mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];
              
              # Add OpenGL and Vulkan support
              hardware.opengl = {
                enable = true;
                driSupport = true;
                driSupport32Bit = true;
              };
              
              # Optional: Set up environment variables system-wide
              environment.variables = {
                VK_ICD_FILENAMES = "${pkgs.lib.makeSearchPath "etc/vulkan/icd.d" (with pkgs; [ vulkan-validation-layers mesa ])}";
              };
            };
          };
      });
}