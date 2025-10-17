#!/usr/bin/env bash

set -euo pipefail

# Script to update Zed package hashes
# This will fetch the latest releases and update the sha256 hashes in flake.nix

CHANNELS=("stable" "preview")
ARCHS=("x86_64" "aarch64")

echo "Updating Zed package hashes..."

for channel in "${CHANNELS[@]}"; do
    for arch in "${ARCHS[@]}"; do
        echo "Fetching ${channel} for ${arch}..."
        
        url="https://zed.dev/api/releases/${channel}/latest/zed-linux-${arch}.tar.gz"
        
        # Get the actual hash and convert to SRI format
        raw_hash=$(nix-prefetch-url --type sha256 "$url")
        hash=$(nix hash convert --hash-algo sha256 "$raw_hash")
        
        echo "  ${channel}/${arch}: ${hash}"
        
        # Update the hash in flake.nix with more precise patterns
        if [[ "$arch" == "x86_64" ]]; then
            if [[ "$channel" == "stable" ]]; then
                sed -i 's|zed-stable.*then "sha256-[^"]*"|zed-stable.*then "'"$hash"'"|g' flake.nix
            else
                sed -i 's|zed-preview.*then "sha256-[^"]*"|zed-preview.*then "'"$hash"'"|g' flake.nix
            fi
        else
            if [[ "$channel" == "stable" ]]; then
                sed -i 's|zed-stable.*else "sha256-[^"]*"|zed-stable.*else "'"$hash"'"|g' flake.nix
            else
                sed -i 's|zed-preview.*else "sha256-[^"]*"|zed-preview.*else "'"$hash"'"|g' flake.nix
            fi
        fi
    done
done

echo "Hashes updated successfully!"
echo "You can now build the packages with: nix build .#zed"