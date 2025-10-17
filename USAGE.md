# Quick Usage Guide

## 1. Direct Usage

```bash
# Run Zed directly from the flake
nix run github:your-username/zed-flake

# Or add to your profile
nix profile install github:your-username/zed-flake
```

## 2. Home Manager Integration

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    zed-flake.url = "github:your-username/zed-flake";
  };

  outputs = { nixpkgs, home-manager, zed-flake, ... }: {
    homeConfigurations.your-username = home-manager.lib.homeManagerConfiguration {
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

## 3. NixOS Integration

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zed-flake.url = "github:your-username/zed-flake";
  };

  outputs = { nixpkgs, zed-flake, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        zed-flake.nixosModules.default
        {
          programs.zed = {
            enable = true;
            channel = "preview";
          };
          
          hardware.opengl.enable = true;
        }
      ];
    };
  };
}
```

## 4. Available Packages

- `zed` / `default`: Stable channel
- `zed-stable`: Explicit stable channel  
- `zed-preview`: Preview channel

## 5. Updating Hashes

When Zed releases new versions, update the hashes:

```bash
# Run the update script
./update-hashes.sh

# Or manually:
nix-prefetch-url --type sha256 https://zed.dev/api/releases/stable/latest/zed-linux-x86_64.tar.gz
nix hash convert --hash-algo sha256 <hash>
# Update flake.nix with the new hash
```

## 6. Troubleshooting

### GLIBC Errors
Enable `nix-ld` in your NixOS configuration:
```nix
programs.nix-ld.enable = true;
```

### GPU Issues
Ensure OpenGL/Vulkan is enabled:
```nix
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
};
```

### Audio Issues
Install PipeWire ALSA plugin:
```bash
sudo apt install pipewire-alsa  # Debian/Ubuntu
```