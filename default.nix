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
    outputHashes = {
      "async-tungstenite-0.28.0" = "sha256-Lh0MzGyJ+q2YxJvLqQ5K+3k3B7Jd4e4j7J3F2G+H+o=";
    "livekit-protocol-0.2.0" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
    "webrtc-sys-0.4.0" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
    "lsp-types-0.95.0" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
    "markdown-0.3.0" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-bash" = "sha256-4pQqV2qJ2vK2fQ5V6R9O8S7N6P5Q4W3O2M1K9L8=";
      "tree-sitter-c" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
      "tree-sitter-cpp" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
      "tree-sitter-css" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-dockerfile" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-elixir" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
      "tree-sitter-erlang" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
      "tree-sitter-gleam" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-go" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-hare" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
      "tree-sitter-html" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
      "tree-sitter-java" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-javascript" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-json" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
      "tree-sitter-nix" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
      "tree-sitter-ocaml" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-php" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-python" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
      "tree-sitter-ruby" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
      "tree-sitter-rust" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-sql" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-toml" = "sha256-8j9k7l6m5n4p3q2r1o0s9t8u7v6x5c4b3n2m1k9l8=";
      "tree-sitter-typescript" = "sha256-7v+X9z+LzQ7j5fX7j6g5h4h3j2k1l9m8n7b6v5c4w3=";
      "tree-sitter-xml" = "sha256-5h4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
      "tree-sitter-yaml" = "sha256-6f5d4g3j2k1l9m8n7b6v5c4w3n2m1k9l8=";
    };
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