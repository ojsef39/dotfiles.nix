{ pkgs, lib, ... }:
let
  # Filter out lazy-lock.json from the source directory
  nvimConfigFiltered = lib.cleanSourceWith {
    src = ./nvim;
    filter = path: type: let
      baseName = baseNameOf path;
    in baseName != "lazy-lock.json";
  };
  treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars);
in
{
  # Packages used in nvim but also outside of it
  home.packages = with pkgs; [
    fzf
    git
    lazygit
    nerdfonts
    ripgrep
  ];

  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = lib.mkDefault true;
    viAlias = lib.mkDefault true;
    vimAlias = lib.mkDefault true;
    withNodeJs = lib.mkDefault true;

    plugins = [
      treeSitterWithAllGrammars
    ];

    # Packages used in nvim
    extraPackages = with pkgs; [
      fd
      nodejs

      # LSP
      vimPlugins.vim-prettier
      # Go
      gofumpt
      goimports-reviser
      gopls
      # Python
      pyright
      ruff
      # Lua
      lua-language-server
      stylua
      # Markdown
      markdownlint-cli2
      marksman
      vimPlugins.vim-markdown-toc
      # Shell
      shfmt
      # YAML
      yaml-language-server
      # JSON
      jsonnet-language-server
    ];
  };

  # Copy your Neovim configuration
  xdg.configFile = {
    # Copy the filtered nvim configuration directory
    "nvim" = {
      source = nvimConfigFiltered;
      recursive = true;
    };
  };

  home.file = {
    # Ensure the .local/share/nvim directory exists with correct permissions
    ".local/share/nvim/.keep" = {
      text = "";
      onChange = ''
        mkdir -p $HOME/.local/share/nvim
        chmod 755 $HOME/.local/share/nvim
      '';
    };

    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    ".local/share/nvim/nix/nvim-treesitter/" = {
      recursive = true;
      source = treeSitterWithAllGrammars;
    };
  };
}
