let
    unstable = import (fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz) {};
in
{
    packageOverrides = pkgs: with pkgs; {
        neovimEnv = pkgs.buildEnv {
            name = "neovimEnv";
            paths = [
                unstable.lua-language-server
                vale
                lazygit
                ripgrep
                gnumake
                unstable.nil
                gcc
                unstable.nodePackages.pyright
                nodePackages_latest.typescript-language-server
                python311Packages.flake8
                rust-analyzer
            ];
        };
    };
}
