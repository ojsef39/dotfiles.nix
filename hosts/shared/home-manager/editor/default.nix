#TODO: https://github.com/bennypowers/nvim-regexplainer
#TODO: https://github.com/yazi-rs/plugins/tree/main/diff.yazi
{
  pkgs,
  lib,
  vars,
  ...
}: let
  # Filter out lazy-lock.json from the source directory
  nvimConfigFiltered = lib.cleanSourceWith {
    src = ./nvim;
    filter = path: _type: let
      baseName = baseNameOf path;
    in
      baseName != "lazy-lock.json";
  };
  treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    _plugins: pkgs.tree-sitter.allGrammars
  );

  # Convert Nix ignorelist to Lua table
  userIgnorelist = vars.nvim.cord.ignorelist or [];
  cordIgnorelist = userIgnorelist ++ [vars.user.name];
  ignorelistToLua = ignorelist: let
    quotedItems = map (item: "'${item}'") ignorelist;
  in "{ ${lib.concatStringsSep ", " quotedItems} }";

  # Convert git callbacks to Lua table
  callbacksToLua = callbacks: let
    entries = lib.mapAttrsToList (url: luaFunc: ''["${url}"] = ${luaFunc}'') callbacks;
  in "{ ${lib.concatStringsSep ", " entries} }";
in {
  # Packages you also want to outside use outside of nvim
  home.packages = with pkgs; [
    claude-code
    codex
    fd
    fzf
    git
    github-copilot-cli
    maple-mono.NF
    nixfmt
    ripgrep
    yq-go
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

    # Packages used in nvim - only include essential runtime dependencies
    extraPackages = with pkgs; [
      # Essential runtime dependencies
      fzf
      nodejs
      ripgrep
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
        require("core.commands")
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

                local get_display_name = function(opts)
                    if is_ignorelisted(opts) then
                        return nil -- Signal that it's ignorelisted
                    end

                    local display_name = opts.filename
                    if opts.workspace_dir then
                        local current_file = vim.fn.expand("%:p")
                        if current_file:find(opts.workspace_dir, 1, true) == 1 then
                            local rel_path = current_file:sub(#opts.workspace_dir + 2)
                            local parts = {}
                            for part in string.gmatch(rel_path, "[^/]+") do
                                table.insert(parts, part)
                            end
                            if #parts >= 2 then
                                local parent_dir = parts[#parts - 1]
                                display_name = parent_dir .. "/" .. opts.filename
                            end
                        end
                    end
                    return display_name
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
                            local display_name = get_display_name(opts)
                            if not display_name then
                                return "Viewing a file"
                            end
                            return "Viewing " .. display_name
                        end,
                        editing = function(opts)
                            local display_name = get_display_name(opts)
                            if not display_name then
                                return "Editing a file"
                            end
                            return string.format("Editing %s - %s errors", display_name, #errors)
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
    "nvim/lua/plugins/gitlinker.lua" = {
      text = ''
        return {
          src = "https://github.com/ruifm/gitlinker.nvim",
          defer = true,
          dependencies = {
            { src = "https://github.com/nvim-lua/plenary.nvim" },
          },
          config = function()
            require("gitlinker").setup({
              opts = {
                add_current_line_on_normal_mode = true,
                action_callback = require("gitlinker.actions").open_in_browser,
                print_url = true,
              },
              callbacks = ${callbacksToLua (vars.git.callbacks or {})},
            })

            -- Keymaps
            vim.keymap.set("n", "<leader>go", function()
              require("gitlinker").get_buf_range_url("n")
            end, { desc = "Git Browse (open in browser)", silent = true })

            vim.keymap.set("n", "<leader>gy", function()
              require("gitlinker").get_buf_range_url(
                "n",
                { action_callback = require("gitlinker.actions").copy_to_clipboard }
              )
            end, { desc = "Git Copy URL", silent = true })

            vim.keymap.set("v", "<leader>go", function()
              require("gitlinker").get_buf_range_url("v")
            end, { desc = "Git Browse selection", silent = true })

            vim.keymap.set("v", "<leader>gy", function()
              require("gitlinker").get_buf_range_url(
                "v",
                { action_callback = require("gitlinker.actions").copy_to_clipboard }
              )
            end, { desc = "Git Copy selection URL", silent = true })
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
