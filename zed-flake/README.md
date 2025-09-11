# Zed Editor Flake

This is a Nix flake that provides the Zed editor, built directly from the source repository to ensure you always have the latest version.

## Usage

### Using the flake directly

```bash
# Run Zed directly
nix run github:your-username/zed-flake

# Enter a development shell
nix develop github:your-username/zed-flake
```

### Adding to your system configuration

#### Home Manager

```nix
# home.nix
{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.zed-flake.packages.${pkgs.system}.default
  ];
}
```

#### NixOS System

```nix
# configuration.nix
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.zed-flake.packages.${pkgs.system}.default
  ];
}
```

### Development

To work on Zed itself:

```bash
# Clone this repository
git clone https://github.com/your-username/zed-flake.git
cd zed-flake

# Enter development environment
nix develop

# Build Zed
nix build
```

## Features

- Always builds from the latest Zed source
- Supports Linux and macOS
- Includes development environment with all necessary tools
- Configurable build options (GLES support, debug builds)
- Uses Nix cache for faster builds

## Maintaining

This flake is designed to be maintained independently. To update:

1. Update the `zed-src` input in `flake.nix` to point to a specific commit or tag
2. Test the build
3. Push updates to your repository

The flake will automatically track the Zed repository and build the latest version.