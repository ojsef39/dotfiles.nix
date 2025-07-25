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

  # Convert Nix ignorelist to Lua table
  userIgnorelist = vars.nvim.cord.ignorelist or [];
  cordIgnorelist = userIgnorelist ++ [ vars.user.name ];
  ignorelistToLua = ignorelist:
    let
      quotedItems = map (item: "'${item}'") ignorelist;
    in "{ ${lib.concatStringsSep ", " quotedItems} }";
in
{
  # Packages you also want to outside use outside of nvim
  home.packages = with pkgs; [
    fd
    fzf
    git
    maple-mono.NF
    ripgrep
    yq
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
      nodejs
      ripgrep

      # LSPs
      vimPlugins.vim-prettier
      nixd
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
    "nvim/lua/plugins/cord.lua" = {
      text = ''
        return {
          {
            'vyfor/cord.nvim',
            build = ':Cord update',
            lazy = true,
            event = "VeryLazy",
            opts = {
              editor = {
                tooltip = "How do I exit this?",
              },
              text = (function()
                local ignorelist = ${ignorelistToLua cordIgnorelist}
                local is_ignorelisted = function(opts)
                  -- Check workspace name
                  for _, item in ipairs(ignorelist) do
                    if opts.workspace == item then
                      return true
                    end
                  end
                  -- Check git remote
                  local remote = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
                  for _, item in ipairs(ignorelist) do
                    if remote:find(item, 1, true) then
                      return true
                    end
                  end
                  return false
                end

                return {
                  viewing = function(opts)
                    return is_ignorelisted(opts) and 'Viewing a file' or ('Viewing ' .. opts.filename)
                  end,
                  editing = function(opts)
                    return is_ignorelisted(opts) and 'Editing a file' or ('Editing ' .. opts.filename)
                  end,
                  workspace = function(opts)
                    return is_ignorelisted(opts) and 'In a secret workspace' or ('Working on ' .. opts.workspace)
                  end
                }
              end)()
            }
          }
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
