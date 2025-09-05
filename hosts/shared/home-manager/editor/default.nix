# TODO: patch following PR into this: <https://github.com/frostplexx/dotfiles.nix/pull/415>
{
  pkgs,
  lib,
  vars,
  ...
}: let
  # Filter out lazy-lock.json from the source directory
  nvimConfigFiltered = lib.cleanSourceWith {
    src = ./nvim;
    filter = path: type: let
      baseName = baseNameOf path;
    in
      baseName != "lazy-lock.json";
  };
  treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    plugins: pkgs.tree-sitter.allGrammars
  );

  # Convert Nix ignorelist to Lua table
  userIgnorelist = vars.nvim.cord.ignorelist or [];
  cordIgnorelist = userIgnorelist ++ [vars.user.name];
  ignorelistToLua = ignorelist: let
    quotedItems = map (item: "'${item}'") ignorelist;
  in "{ ${lib.concatStringsSep ", " quotedItems} }";
in {
  # Packages you also want to outside use outside of nvim
  home.packages = with pkgs; [
    claude-code
    fd
    fzf
    git
    maple-mono.NF
    nixfmt
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
      python3Packages.black
      python3Packages.isort
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
      # Formatters
      nodePackages.prettier
      rustfmt
      alejandra
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
    "nvim/init.lua" = {
      text = ''
        -- Global variables.
        vim.g.projects_dir = vim.env.HOME .. "/${vars.git.ghq}"
        vim.g.nix_dir = vim.fn.expand("${vars.git.nix}")

        -- [[ Lazy.nvim Plugin Manager ]]

        -- Install Lazy
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
            vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable", -- latest stable release
                lazypath,
            })
        end
        vim.opt.rtp = vim.opt.rtp ^ lazypath

        ---@diagnostic disable-next-line: undefined-doc-name
        ---@type LazySpec
        local plugins = "plugins"

        -- General Setup
        require("globals") -- needs to be first
        require("core")
        require("config")

        -- initialize lazy.nvim
        require("lazy").setup(plugins, {
            ui = { border = "rounded" },
            dev = {
                path = "~/.local/share/nvim/nix",
                fallback = false,
            },
            defaults = {
                lazy = true,
                version = nil,
            },
            change_detection = {
                notify = true,
                enabled = true,
            },
            rocks = { enabled = false },
            checker = {
                enabled = false,
                notify = false,
            },
            performance = {
                cache = {
                    enabled = true,
                },
                reset_packpath = true, -- Reset packpath for better performance
                rtp = {
                    reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
                    -- disable some rtp plugins
                    disabled_plugins = {
                        "gzip",
                        "matchit",
                        "matchparen",
                        "netrwPlugin",
                        "tarPlugin",
                        "tohtml",
                        "tutor",
                        "zipPlugin",
                        "rplugin", -- Disable remote plugins
                        "syntax", -- Disable vim syntax (use treesitter)
                    },
                },
            },
            profiling = {
                loader = false,
                require = false,
            },
        })

        require("ui")
        vim.cmd.colorscheme("catppuccin-macchiato")
      '';
    };
    # Discord Rich Presence Configuration
    "nvim/lua/plugins/cord.lua" = {
      text = ''
        return {
            "vyfor/cord.nvim",
            build = ":Cord update",
            lazy = true,
            event = "VeryLazy",
            config = function()
                local errors = {}
                local get_errors = function(bufnr)
                    return vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
                end

                -- Debounce error updates
                local timer = vim.uv.new_timer()
                vim.api.nvim_create_autocmd("DiagnosticChanged", {
                    callback = function()
                        timer:stop()
                        timer:start(
                            500,
                            0,
                            vim.schedule_wrap(function()
                                errors = get_errors(0)
                            end)
                        )
                    end,
                })

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

                require("cord").setup({
                    editor = {
                        tooltip = "How do I exit this?",
                    },
                    idle = {
                        details = function(opts)
                            return is_ignorelisted(opts) and "Taking a break from a secret workspace"
                                or string.format("Taking a break from %s", opts.workspace)
                        end,
                    },
                    text = {
                        viewing = function(opts)
                            return is_ignorelisted(opts) and "Viewing a file" or ("Viewing " .. opts.filename)
                        end,
                        editing = function(opts)
                            if is_ignorelisted(opts) then
                                return "Editing a file"
                            else
                                return string.format("Editing %s - %s errors", opts.filename, #errors)
                            end
                        end,
                        workspace = function(opts)
                            return is_ignorelisted(opts) and "In a secret workspace"
                                or string.format("Working on %s", opts.workspace)
                        end,
                    },
                })
            end,
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
