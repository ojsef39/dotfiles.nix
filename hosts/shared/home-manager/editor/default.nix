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
    package = pkgs.neovim; # This will use the nightly version from the overlay
    defaultEditor = lib.mkDefault true;
    viAlias = lib.mkDefault true;
    vimAlias = lib.mkDefault true;
    withNodeJs = lib.mkDefault true;

    plugins = [
      # treeSitterWithAllGrammars
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

        vim.loader.enable()

        local unpack_path = vim.fn.stdpath("data") .. "/site/pack/managers/start/unpack"

        if not vim.uv.fs_stat(unpack_path) then
            vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/mezdelex/unpack",
                unpack_path,
            })
        end

        require("globals")
        require("core.autocmds")
        require("core.keymaps")
        require("core.options")
        require("ui")
        require("core.lsp")
        require("unpack").setup()
      '';
    };
    # Discord Rich Presence Configuration
    "nvim/lua/plugins/neocord.lua" = {
      text = ''
        return {
            src = "https://github.com/vyfor/cord.nvim",
            name = "cord.nvim",
            defer = true,
            data = { build = ":Cord update" },
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

                local ignorelist = { "git.mam.dev", "jhofer" }
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
