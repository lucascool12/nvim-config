let
    unstable = import (fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz) {};
in
{
    packageOverrides = pkgs: with pkgs; {
        neovimEnv = pkgs.buildEnv {
            name = "neovimEnv";
            paths = [
                unstable.lua-language-server
                lazygit
                ripgrep
                gnumake
                tree-sitter
            ];
        };
    };
}
