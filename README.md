# Zed Editor Flake

This is a Nix flake that provides the Zed editor, built directly from the source repository to ensure you always have the latest version.

## Quick Start

```bash
# Run Zed directly
nix run github:MichaelFisher1997/zed-flake

# Install to your system
nix profile install github:MichaelFisher1997/zed-flake
```

## Features

- **Always up-to-date**: Builds directly from the Zed source repository
- **Multiple configurations**: Standard, GLES, and debug builds
- **Cross-platform**: Supports Linux and macOS
- **Development environment**: Complete toolchain for Zed development
- **Easy integration**: Works with Home Manager and NixOS

## Usage

### Running Zed

```bash
# Standard build
nix run github:MichaelFisher1997/zed-flake

# GLES build (for systems with limited Vulkan support)
nix run github:MichaelFisher1997/zed-flake#zed-gles

# Debug build
nix run github:MichaelFisher1997/zed-flake#zed-debug
```

### Development Shell

```bash
# Standard development environment
nix develop github:MichaelFisher1997/zed-flake

# GLES development environment
nix develop github:MichaelFisher1997/zed-flake#gles

# Debug development environment
nix develop github:MichaelFisher1997/zed-flake#debug
```

### System Integration

#### Home Manager

```nix
# home.nix
{ inputs, ... }: {
  inputs.zed-flake.url = "github:MichaelFisher1997/zed-flake";
  
  # Then add to your configuration
  home.packages = [ inputs.zed-flake.packages.${pkgs.system}.default ];
}
```

#### NixOS System

```nix
# configuration.nix
{ inputs, ... }: {
  inputs.zed-flake.url = "github:MichaelFisher1997/zed-flake";
  
  # Then add to your configuration
  environment.systemPackages = [ inputs.zed-flake.packages.${pkgs.system}.default ];
}
```

### Local Development

```bash
# Clone this repository
git clone https://github.com/MichaelFisher1997/zed-flake.git
cd zed-flake

# Build Zed
nix build

# Enter development environment
nix develop

# Run tests
nix develop --command cargo test
```

## Available Packages

- `default`: Standard Zed editor build
- `zedGLES`: Zed with OpenGL ES support
- `zedDebug`: Debug build with additional logging

## Maintaining

This flake is designed to be maintained independently. To update:

1. The `zed-src` input automatically tracks the latest Zed commits
2. For specific versions, pin the `zed-src` input to a commit hash:
   ```nix
   zed-src = {
     url = "github:zed-industries/zed/commit_hash";
     flake = false;
   };
   ```
3. Test builds across different systems
4. Push updates to your repository

## Building Options

The flake supports multiple build configurations:

- **Standard**: Default release build with Vulkan
- **GLES**: Release build with OpenGL ES (better compatibility)
- **Debug**: Development build with debug symbols

## Troubleshooting

If you encounter build issues:

1. Ensure your system has enough RAM (Zed requires ~8GB for compilation)
2. Try the GLES build if you have graphics driver issues
3. Check the Zed repository for known build issues
4. Use the debug build for better error messages

## Contributing

1. Fork this repository
2. Make your changes
3. Test builds on multiple platforms if possible
4. Submit a pull request to https://github.com/MichaelFisher1997/zed-flake

## License

This flake is MIT licensed. Zed itself is licensed under the GPL-3.0 license.