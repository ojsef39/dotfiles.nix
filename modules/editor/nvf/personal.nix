{
  # Editor integrations with personal-only services: Discord presence and the
  # non-Claude AI assistants. claudecode.nvim stays in base (_parts/plugins-custom.nix).
  flake.modules.homeManager.personal = {
    pkgs,
    lib,
    vars,
    ...
  }: let
    # Convert Nix ignoreList to Lua table for cord
    userIgnoreList = vars.nvim.cord.ignoreList;
    cordIgnoreList = userIgnoreList ++ [vars.user.name];
    ignoreListToLua = ignoreList: let
      quotedItems = map (item: "'${item}'") ignoreList;
    in "{ ${lib.concatStringsSep ", " quotedItems} }";
  in {
    programs.nvf.settings.vim = {
      # Copilot AI assistant
      assistant = {
        copilot = {
          enable = true;
          cmp.enable = true;
          mappings.suggestion = {
            accept = "<C-j>";
            acceptWord = "<C-l>";
            acceptLine = "<C-k>";
            next = "<C-n>";
            prev = "<C-p>";
            dismiss = "<C-h>";
          };
          setupOpts = {
            suggestion = {
              enabled = true;
              auto_trigger = true;
              debounce = 75;
            };
            filetypes = {
              "*" = true;
              help = false;
              gitrebase = false;
              hgcommit = false;
              svn = false;
              cvs = false;
            };
            should_attach = lib.generators.mkLuaInline ''
              function(_, bufname)
                if string.match(bufname, "%.env") then
                  return false
                end
                return true
              end
            '';
          };
        };
      };

      extraPlugins = {
        # Copilot Chat
        copilot-chat = {
          package = pkgs.vimPlugins.CopilotChat-nvim;
          setup = ''
            require("CopilotChat").setup({
              model = "claude-sonnet-4.5",
              window = {
                layout = "vertical",
                width = 0.3,
                height = 0.8,
                relative = "editor",
                border = "single",
              },
              chat = {
                welcome_message = false,
              },
              mappings = {
                complete = {
                  insert = "",
                },
                reset = {
                  normal = "<C-c>",
                  insert = "",
                },
                close = {
                  normal = "q",
                  insert = "",
                },
              },
            })

            -- Autocmd for chat buffer
            vim.api.nvim_create_autocmd("BufEnter", {
              pattern = "copilot-chat",
              callback = function()
                vim.opt_local.relativenumber = false
                vim.opt_local.number = false
              end,
            })

            -- Keymaps
            vim.keymap.set({ "n", "v" }, "<leader>ap", function()
              return require("CopilotChat").toggle()
            end, { desc = "Toggle Copilot Chat", silent = true })

            vim.keymap.set({ "n", "v" }, "<leader>ax", function()
              return require("CopilotChat").reset()
            end, { desc = "Clear Copilot Chat", silent = true })
          '';
        };

        # OpenCode - AI coding assistant
        opencode = {
          package = pkgs.vimPlugins.opencode-nvim;
          setup = ''
            vim.g.opencode_opts = {}
            vim.o.autoread = true

            -- AI commands under <leader>a (alongside Claude, CopilotChat)
            vim.keymap.set({ "n", "x" }, "<leader>ao", function()
              require("opencode").ask("@this: ", { submit = true })
            end, { desc = "Ask OpenCode", silent = true })

            vim.keymap.set({ "n", "x" }, "<leader>aO", function()
              require("opencode").select()
            end, { desc = "OpenCode command picker", silent = true })

            vim.keymap.set({ "n", "x" }, "<leader>aa", function()
              require("opencode").prompt("@this")
            end, { desc = "Add to OpenCode", silent = true })
          '';
        };

        # Discord Rich Presence
        cord = {
          package = pkgs.vimPlugins.cord-nvim;
          setup = ''
            local ignoreList = ${ignoreListToLua cordIgnoreList}
            local is_ignoreListed = function(opts)
              -- Check workspace name
              for _, item in ipairs(ignoreList) do
                if opts.workspace == item then
                  return true
                end
              end
              -- Check git remote
              local remote = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
              for _, item in ipairs(ignoreList) do
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
              text = {
                viewing = function(opts)
                  return is_ignoreListed(opts) and 'Viewing a file' or ('Viewing ' .. opts.filename)
                end,
                editing = function(opts)
                  return is_ignoreListed(opts) and 'Editing a file' or ('Editing ' .. opts.filename)
                end,
                workspace = function(opts)
                  return is_ignoreListed(opts) and 'In a secret workspace' or ('Working on ' .. opts.workspace)
                end,
              },
              idle = {
                enabled = true,
                timeout = 300000,
                show_status = false,
                smart_idle = true,
                unidle_on_focus = true,
              },
            })
          '';
        };
      };
    };
  };
}
