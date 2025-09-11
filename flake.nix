{
  description = "Zed Editor - A high-performance, multiplayer code editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zed-version = "0.203.4";
        zed-src = pkgs.fetchurl {
          url = "https://github.com/zed-industries/zed/releases/download/v${zed-version}/zed-linux-x86_64.tar.gz";
          sha256 = "0y0p83s1w2r52mjrfc9cvnxhg8shdvyy5j9dq4x22wysgwigndpp";
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zed";
          version = zed-version;

          src = zed-src;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          unpackPhase = ''
            tar -xzf $src
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp zed.app/bin/zed $out/bin/
            
            # Wrap the binary to ensure it can find necessary libraries
            wrapProgram $out/bin/zed \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
                pkgs.stdenv.cc.cc.lib
                pkgs.xorg.libX11
                pkgs.xorg.libXcursor
                pkgs.xorg.libXi
                pkgs.xorg.libXrandr
                pkgs.wayland
                pkgs.libxkbcommon
                pkgs.vulkan-loader
              ]} \
              --set XDG_RUNTIME_DIR "/run/user/$(id -u)"
          '';

          meta = with pkgs.lib; {
            description = "A high-performance, multiplayer code editor";
            homepage = "https://zed.dev";
            license = licenses.unfree;
            platforms = [ "x86_64-linux" ];
            maintainers = [ maintainers.micqdf ];
          };
        };

        apps.zed = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/zed";
        };
        
        apps.default = self.apps.${system}.zed;
      });
}