# Zed Editor Nix Flake

A [Nix flake](https://nixos.wiki/wiki/Flakes) for the [Zed Code Editor](https://zed.dev) that provides easy installation for both NixOS and Home Manager users.

## Features

- 🚀 Latest stable and preview releases
- 🏗️ Works on both `x86_64-linux` and `aarch64-linux`
- 🖥️ Desktop integration (`.desktop` file, icons)
- 🔧 Automatic dependency management (Vulkan, OpenGL, etc.)
- 📦 Home Manager and NixOS modules
- 🎯 Shell completion support

## Quick Start

### Using the flake directly

```bash
# Run Zed from the flake
nix run github:your-username/zed-flake

# Or add to your configuration
nix profile install github:your-username/zed-flake
```

### Home Manager

Add to your `home.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zed-flake.url = "github:your-username/zed-flake";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, zed-flake, ... }:
    {
      homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          zed-flake.homeManagerModules.default
          {
            programs.zed = {
              enable = true;
              channel = "stable"; # or "preview"
            };
          }
        ];
      };
    };
}
```

### NixOS

Add to your `configuration.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zed-flake.url = "github:your-username/zed-flake";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, zed-flake, ... }:
    {
      nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          zed-flake.nixosModules.default
          {
            programs.zed = {
              enable = true;
              channel = "stable"; # or "preview"
            };
            
            # Enable hardware acceleration
            hardware.opengl.enable = true;
          }
        ];
      };
    };
}
```

## Available Packages

- `zed` (default): Stable channel
- `zed-stable`: Explicit stable channel
- `zed-preview`: Preview channel (gets updates ~1 week earlier)

## Manual Installation

If you prefer not to use the modules:

```bash
# Install stable version
nix profile install .#zed-stable

# Install preview version  
nix profile install .#zed-preview
```

## Requirements

### System Dependencies

The flake automatically handles most dependencies, but Zed requires:

- **Vulkan-compatible GPU** for hardware acceleration
- **glibc** compatibility (NixOS users may need `nix-ld`)

### NixOS Configuration

For optimal performance, ensure your NixOS configuration includes:

```nix
{
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # Optional: For better compatibility with pre-built binaries
  programs.nix-ld.enable = true;
}
```

### Home Manager

```nix
{
  # Optional: Set up environment variables
  home.sessionVariables = {
    VK_ICD_FILENAMES = "${pkgs.lib.makeSearchPath "etc/vulkan/icd.d" (with pkgs; [ vulkan-validation-layers mesa.drivers ])}";
  };
}
```

## Troubleshooting

### Zed fails to start with GLIBC errors

Zed requires glibc >= 2.31 (x86_64) or >= 2.35 (aarch64). On NixOS, you can:

1. Enable `nix-ld`:
   ```nix
   programs.nix-ld.enable = true;
   ```

2. Or build from source (see [Zed's Linux documentation](https://zed.dev/docs/linux))

### Graphics issues

If you encounter GPU-related errors:

1. **Check Vulkan support**:
   ```bash
   vkcube
   ```

2. **Install appropriate drivers**:
   ```nix
   hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [ vulkan-validation-layers ];
   };
   ```

3. **Force specific GPU** (if needed):
   ```bash
   ZED_DEVICE_ID=0x1234 zed
   ```

### Audio issues

Zed uses ALSA for audio output. The flake includes `alsa-lib` as a dependency, but you may need additional configuration:

**For PipeWire/PulseAudio systems:**
```bash
# On Debian/Ubuntu
sudo apt install pipewire-alsa

# Or configure ~/.asoundrc:
pcm.!default {
    type pipewire;
}
```

**For NixOS systems:**
```nix
# Add to your configuration.nix
hardware.pulseaudio.enable = true;
# or for PipeWire:
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};
```

## Updating Hashes

The pre-computed hashes in `flake.nix` will become outdated as Zed releases new versions. To update:

1. Try building with the current hashes (it will fail with the correct hash)
2. Replace the fake hashes in the error message
3. Or use `nix run .#zed --update` (if supported)

## Contributing

1. Fork this repository
2. Update the hashes when new Zed versions are released
3. Test on both stable and preview channels
4. Submit a pull request

## License

This flake is licensed under the MIT License. Zed itself is licensed under GPL-3.0-or-later.

## Related Links

- [Zed Official Website](https://zed.dev)
- [Zed Linux Documentation](https://zed.dev/docs/linux)
- [Zed GitHub Repository](https://github.com/zed-industries/zed)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)