{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  fontconfig,
  freetype,
  libgit2,
  curl,
  sqlite,
  zlib,
  zstd,
  alsa-lib,
  libxkbcommon,
  wayland,
  vulkan-loader,
  xorg,
  makeWrapper,
  nodejs,
  protobuf,
  cmake,
  perl,

  # Optional parameters
  withGLES ? false,
  profile ? "release",
}:

let
  gpu-lib = if withGLES then vulkan-loader else vulkan-loader;
  buildProfile = if profile == "dev" then "debug" else profile;
in
rustPlatform.buildRustPackage rec {
  pname = "zed-editor";
  version = "0.142.1-nightly";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "zed";
    rev = "aee21ca17f5408f0fddb839ba60f79485eae385d";
    hash = "sha256-/q3R1yqVaCP40di0C2LqeOu/rkxhwLeYQmb+bUnd3Eo=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
    protobuf
    perl
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    fontconfig
    freetype
    libgit2
    curl
    sqlite
    zlib
    zstd
    alsa-lib
    libxkbcommon
    wayland
    gpu-lib
    xorg.libX11
    xorg.libxcb
    nodejs
  ];

  buildFeatures = [ "gpui/runtime_shaders" ];

  cargoBuildFlags = [ "-p zed" "-p cli" ];

  postInstall = ''
    # Install desktop entry and icons
    install -D "${src}/crates/zed/resources/app-icon-nightly@2x.png" \
      "$out/share/icons/hicolor/1024x1024@2x/apps/zed.png"
    install -D "${src}/crates/zed/resources/app-icon-nightly.png" \
      "$out/share/icons/hicolor/512x512/apps/zed.png"

    # Create desktop entry
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/dev.zed.Zed-Nightly.desktop" << EOF
    [Desktop Entry]
    Type=Application
    Name=Zed Nightly
    Comment=A high-performance, multiplayer code editor
    Exec=$out/bin/zed %U
    Icon=zed
    Terminal=false
    Categories=Development;TextEditor;
    StartupNotify=true
    EOF
    chmod +x "$out/share/applications/dev.zed.Zed-Nightly.desktop"

    # Wrap the binary to include necessary libraries and node
    wrapProgram "$out/bin/zed" \
      --suffix PATH : "${lib.makeBinPath [ nodejs ]}" \
      --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gpu-lib wayland ]}"
  '';

  meta = {
    description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
    homepage = "https://zed.dev";
    changelog = "https://zed.dev/releases/preview";
    license = lib.licenses.gpl3Only;
    mainProgram = "zed";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}