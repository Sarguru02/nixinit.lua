# Nix + Neovim Configuration

A personal Neovim configuration packaged as a Nix flake with Lua configuration that doesn't interfere with your existing setup.

## Quick Start

### Prerequisites

Install Nix with flakes enabled:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### Installation

#### Try without cloning
```bash
nix run "github:Sarguru02/nixinit.lua"
```

#### Clone and run locally
```bash
git clone https://github.com/Sarguru02/nixinit.lua.git
cd nixinit.lua
nix run
```

## File Structure

```
├── flake.lock
├── flake.nix
├── init.lua
├── lua
│   └── config
│       ├── init.lua
│       ├── lazy.lua
│       ├── maps.lua
│       ├── opts.lua
│       ├── plugins
│       │   ├── blink.lua
│       │   ├── comment.lua
│       │   ├── csv.lua
│       │   ├── format.lua
│       │   ├── gitblame.lua
│       │   ├── gitsigns.lua
│       │   ├── harpoon.lua
│       │   ├── init.lua
│       │   ├── lsp.lua
│       │   ├── mason.lua
│       │   ├── mini.lua
│       │   ├── navigator.lua
│       │   ├── noice.lua
│       │   ├── snacks.lua
│       │   ├── theme.lua
│       │   └── treesitter.lua
│       └── tabs.lua
└── README.md
```


## Using with Your Own Configuration

1. Copy the `flake.nix` file to your Neovim config directory
2. Modify the `runtimeDeps` list with your required packages
3. Run `nix run` to launch Neovim with your configuration

## Development

To contribute or modify this configuration:

```bash
git clone https://github.com/Sarguru02/nixinit.lua.git
cd nixinit.lua
# Make your changes
nix run  # Test your changes
```
