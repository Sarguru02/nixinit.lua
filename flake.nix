{
  description = "Sarguru's neovim config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    colorscripts = {
      url = "github:Sarguru02/pokemon-colorscripts-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, colorscripts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem = { config, system, ... }: 
        let
          pkgs = nixpkgs.legacyPackages.${system};
          runtimeDeps = with pkgs; [
            hello
            gcc
            fzf
            ripgrep
            curl
            git
            prettierd
            lua-language-server
            nixd
            python313Packages.python-lsp-server
            tinymist
            rust-analyzer

            #colorscripts
            coreutils
            colorscripts.packages.${system}.default

            # Conform
            stylua
            markdown-oxide
            yamllint
            yamlfmt

            # Lint
            tflint
            tfsec
            markdownlint-cli2
            deadnix
            nix
            lua54Packages.luacheck

            #blink
            cargo
          ];

          nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (
            pkgs.neovimUtils.makeNeovimConfig {
              customRC = ''
                set runtimepath^=${./.}
                lua << EOF
                  local config_path = "${./.}/lua"
                  package.path = config_path .. "/?.lua;" .. config_path .. "/?/init.lua;" .. package.path
                  dofile("${./.}/init.lua")
                EOF
              '';
            } // {
              wrapperArgs = [
                "--prefix"
                "PATH"
                ":"
                "${pkgs.lib.makeBinPath runtimeDeps}"
              ];
            }
          );
        in {
          packages = {
            default = nvim;
            neovim = nvim;
          };

          devShells.default = pkgs.mkShell {
            packages = [ nvim ];
          };
        };
    };
}
