# Example Home Manager configuration using the Zed flake
# Save this as ~/.config/home-manager/home.nix or include in your existing config

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Add the Zed flake
    zed-flake.url = "github:your-username/zed-flake";
    zed-flake.inputs.nixpkgs.follows = "nixpkgs";
    zed-flake.inputs.flake-utils.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, zed-flake, ... }:
    {
      homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          # Import the Zed Home Manager module
          zed-flake.homeManagerModules.default
          
          # Your Home Manager configuration
          {
            # Enable Zed with stable channel
            programs.zed = {
              enable = true;
              channel = "stable";
            };
            
            # Optional: Add other programs
            programs.git.enable = true;
            programs.bash.enable = true;
            
            # Home Manager state version
            home.stateVersion = "23.11";
            
            # Optional: Set up environment variables for better GPU support
            home.sessionVariables = {
              EDITOR = "zed";
            };
          }
        ];
      };
    };
}