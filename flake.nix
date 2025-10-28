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

  outputs = inputs@{ nixpkgs, flake-parts, colorscripts, ... }:
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
            markdown-oxide
            haskellPackages.haskell-language-server
            vtsls

            # Formatters
            prettierd
            stylua
            yamlfmt
            gofumpt

            # Linters
            yamllint
            markdownlint-cli2
            deadnix
            nix
            lua54Packages.luacheck

            # Build tools
            cargo

            # Colorscripts
            colorscripts.packages.${system}.default
          ];

          nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (
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
            }
          );
        in {
          packages = {
            default = nvim;
            neovim = nvim;
            
            package-sizes = pkgs.writeShellScriptBin "package-sizes" ''
              echo "=== Runtime Dependencies Size Analysis ==="
              echo ""
              
              total_bytes=0
              
              ${pkgs.lib.concatMapStringsSep "\n" (pkg: 
                let
                  pkgName = pkg.name or pkg.pname or "unknown";
                  pkgPath = "${pkg}";
                in ''
                echo "Calculating size for ${pkgName}..."
                size_output=$(${pkgs.nix}/bin/nix path-info --closure-size ${pkgPath} 2>/dev/null || echo "")
                if [ -n "$size_output" ]; then
                  size_bytes=$(echo "$size_output" | ${pkgs.gawk}/bin/awk '{print $NF}')
                  size_mb=$(echo "scale=2; $size_bytes/1024/1024" | ${pkgs.bc}/bin/bc)
                  size_gb=$(echo "scale=4; $size_bytes/1024/1024/1024" | ${pkgs.bc}/bin/bc)
                  
                  gb_check=$(echo "$size_gb >= 1" | ${pkgs.bc}/bin/bc)
                  if [ "$gb_check" = "1" ]; then
                    printf "%-40s %8s GB\n" "${pkgName}:" "$size_gb"
                  else
                    printf "%-40s %8s MB\n" "${pkgName}:" "$size_mb"
                  fi
                  
                  total_bytes=$((total_bytes + size_bytes))
                else
                  printf "%-40s %8s\n" "${pkgName}:" "ERROR"
                fi
              '') runtimeDeps}
              
              echo ""
              echo "=== TOTAL SIZE ==="
              total_mb=$(echo "scale=2; $total_bytes/1024/1024" | ${pkgs.bc}/bin/bc)
              total_gb=$(echo "scale=4; $total_bytes/1024/1024/1024" | ${pkgs.bc}/bin/bc)
              
              total_gb_check=$(echo "$total_gb >= 1" | ${pkgs.bc}/bin/bc)
              if [ "$total_gb_check" = "1" ]; then
                echo "Total closure size: $total_gb GB ($total_mb MB)"
              else
                echo "Total closure size: $total_mb MB"
              fi
            '';
          };

          devShells.default = pkgs.mkShell {
            packages = [ nvim ];
          };
        };
    };
}
