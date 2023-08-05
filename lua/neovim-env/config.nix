{
    packageOverrides = pkgs: with pkgs; {
        neovimEnv = pkgs.buildEnv {
            name = "neovimEnv";
            paths = [
                (import <nixos-unstable>{}).lua-language-server
                lazygit
                ripgrep
                gnumake
                tree-sitter
            ];
        };
    };
}
