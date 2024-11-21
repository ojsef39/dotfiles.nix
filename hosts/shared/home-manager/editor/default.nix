{ pkgs, lib, vars, ... }:
let
  # Filter out lazy-lock.json from the source directory
  nvimConfigFiltered = lib.cleanSourceWith {
    src = ./nvim;
    filter = path: type: let
      baseName = baseNameOf path;
    in baseName != "lazy-lock.json";
  };
  treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars);
  nvim.presence.blacklist = vars.nvim.presence.blacklist or "";
in
{
  # Packages you also want to outside use outside of nvim
  home.packages = with pkgs; [
    fd
    fzf
    git
    lazygit
    (nerdfonts.override {
      fonts = [ "JetBrainsMono" ];
    })
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
      fzf
      lazygit
      nodejs
      ripgrep

      # LSPs
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
      # git
      actionlint
    ];
  };

  xdg.configFile = {
    # Copy the filtered nvim configuration directory
    "nvim" = {
      source = nvimConfigFiltered;
      recursive = true;
    };
    
    # Discord Rich Presence Configuration
    "nvim/lua/plugins/presence.lua" = {
      text = ''
        return {
          -- add symbols-outline
          {
            "andweeb/presence.nvim",
            -- cmd = "SymbolsOutline",
            lazy = true,
            event = "VeryLazy",
            -- keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
            opts = {
              -- General options
              auto_update = true, -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
              neovim_image_text = "How do I exit this?", -- Text displayed when hovered over the Neovim image
              main_image = "file", -- Main image display (either "neovim" or "file")
              client_id = "793271441293967371", -- Use your own Discord application client id (not recommended)
              log_level = nil, -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
              debounce_timeout = 10, -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
              enable_line_number = false, -- Displays the current line number instead of the current project
              blacklist = { "${toString nvim.presence.blacklist}" }, -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
              buttons = true, -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
              file_assets = {}, -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
              show_time = true, -- Show the timer

              -- Rich Presence text options
              editing_text = "Editing %s", -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
              file_explorer_text = "Browsing %s", -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
              git_commit_text = "Committing changes", -- Format string rendered when committing changes in git (either string or function(filename: string): string)
              plugin_manager_text = "Managing plugins", -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
              reading_text = "Reading %s", -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
              workspace_text = "Working on %s", -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
              line_number_text = "Line %s out of %s", -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
            },
          },
        }
      '';
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
