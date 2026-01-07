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
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, colorscripts, neovim-nightly-overlay, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem = { system, ... }: 
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-nightly = import nixpkgs{
            inherit system;
            overlays = [neovim-nightly-overlay.overlays.default];
          };
          # TODO: Remove all the language servers, and keep them in project's nix file
          runtimeDeps = with pkgs; [
            # Core utilities
            gcc
            fzf
            ripgrep
            curl
            git
            coreutils

            # LSP servers
            lua-language-server
            clang-tools
            gopls
            nodePackages.typescript-language-server
            deno
            nixd
            python313Packages.python-lsp-server
            rust-analyzer
            vtsls

            # Formatters
            prettierd
            stylua
            yamlfmt
            gofumpt

            # Linters
            yamllint
            deadnix
            nix
            lua54Packages.luacheck

            # Build tools
            cargo

            # Colorscripts
            colorscripts.packages.${system}.default
          ];

          nvimConfig = 
            pkgs.neovimUtils.makeNeovimConfig {
              customRC = ''
                set runtimepath^=${./.}
                lua << EOF
                  local fn = vim.fn

                  local flake_config = "${./.}"
                  local flake_init = flake_config .. "/init.lua"

                  local nvim_appname = os.getenv("NVIM_APPNAME")
                  local user_config = fn.stdpath("config")
                  local user_init = user_config .. "/init.lua"

                  if nvim_appname and fn.filereadable(user_config) then 
                    dofile(user_init)
                  else 
                    package.path = flake_config .. "/lua/?.lua;" .. flake_config .. "/lua/?/init.lua"
                    dofile(flake_init)
                  end
                EOF
              '';
            } // {
              wrapperArgs = [
                "--prefix"
                "PATH"
                ":"
                "${pkgs.lib.makeBinPath runtimeDeps}"
              ];
            };
          

          nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped nvimConfig;
          nightly = pkgs-nightly.wrapNeovimUnstable pkgs-nightly.neovim-unwrapped nvimConfig;
          nightly-renamed = nightly.overrideAttrs (old: {
            pname = "nvim-nightly";
            __intentionallyOverridingVersion = true;
            version = old.version or "unstable";
            postFixup = ''
              mv $out/bin/nvim $out/bin/nvim-nightly
            '';
          });
        in {
          packages = rec {
            default = neovim;
            neovim = nvim;
            nvim-nightly = nightly-renamed; 
          };

          devShells.default = pkgs.mkShell {
            packages = with self.packages.${system};[
              nvim
              nvim-nightly
            ];
          };
        };
    };
}
