# Example NixOS configuration using the Zed flake
# Save this as /etc/nixos/configuration.nix or include in your existing config

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Add the Zed flake
    zed-flake.url = "github:your-username/zed-flake";
    zed-flake.inputs.nixpkgs.follows = "nixpkgs";
    zed-flake.inputs.flake-utils.follows = "nixpkgs";
  };

  outputs = { nixpkgs, zed-flake, ... }:
    {
      nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the Zed NixOS module
          zed-flake.nixosModules.default
          
          # Your NixOS configuration
          ({ config, pkgs, ... }: {
            # Enable Zed with preview channel
            programs.zed = {
              enable = true;
              channel = "preview";
            };
            
            # Enable hardware acceleration for Zed
            hardware.opengl = {
              enable = true;
              driSupport = true;
              driSupport32Bit = true;
            };
            
            # Optional: Enable nix-ld for better binary compatibility
            programs.nix-ld.enable = true;
            
            # Optional: Add additional system packages
            environment.systemPackages = with pkgs; [
              git
              curl
              wget
            ];
            
            # Basic system configuration
            system.stateVersion = "23.11";
            
            # Boot configuration
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            
            # Networking
            networking.networkmanager.enable = true;
            
            # Time zone
            time.timeZone = "America/New_York";
            
            # User configuration
            users.users.your-username = {
              isNormalUser = true;
              description = "Your Name";
              extraGroups = [ "networkmanager" "wheel" ];
            };
          })
        ];
      };
    };
}