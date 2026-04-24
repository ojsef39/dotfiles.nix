{
  pkgs,
  lib,
  vars,
  ...
}: let
  # Convert Nix ignoreList to Lua table for cord
  userIgnoreList = vars.nvim.cord.ignoreList or [];
  cordIgnoreList = userIgnoreList ++ [vars.user.name];
  ignoreListToLua = ignoreList: let
    quotedItems = map (item: "'${item}'") ignoreList;
  in "{ ${lib.concatStringsSep ", " quotedItems} }";
in {
  extraPlugins = {
    schemastore = {
      package = pkgs.vimPlugins.SchemaStore-nvim;
    };
    plenary = {
      package = pkgs.vimPlugins.plenary-nvim;
    };

    # Treesitter incremental selection (restores functionality removed from main branch)
    treesitter-modules = {
      package = pkgs.vimPlugins.treesitter-modules-nvim;
      setup = ''
        require("treesitter-modules").setup({
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "<C-space>",
              node_incremental = "V",
              scope_incremental = false,
              node_decremental = "v",
            },
          },
        })
      '';
    };

    # nvim-dap-virtual-text
    nvim-dap-virtual-text = {
      package = pkgs.vimPlugins.nvim-dap-virtual-text;
      setup = ''
        require("nvim-dap-virtual-text").setup({
          virt_text_pos = "eol",
        })
      '';
    };

    # Claude Code
    claudecode = {
      package = pkgs.vimPlugins.claudecode-nvim;
      setup = ''
        require("claudecode").setup({
          terminal = {
            provider = "none", -- Don't open terminal in nvim, use external Claude Code instance
          },
        })

        -- AI commands under <leader>a
        vim.keymap.set("n", "<leader>a", "", { desc = "AI" })
        vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer to Claude", silent = true })
        vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude", silent = true })
        vim.keymap.set("n", "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff", silent = true })
        vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff", silent = true })
      '';
    };

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

    # Lazygit
    lazygit = {
      package = pkgs.vimPlugins.lazygit-nvim;
      setup = ''
        vim.g.lazygit_floating_window_border_chars = { "", "", "", "", "", "", "", "" }
        vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
      '';
    };

    # No neck pain
    no-neck-pain = {
      package = pkgs.vimPlugins.no-neck-pain-nvim;
      setup = ''
        require("no-neck-pain").setup({
          autocmds = {
            enableOnVimEnter = false,
          },
          width = 150,
          mappings = {
            enabled = false,
          },
          buffers = {
            colors = {
              blend = -0.2,
              backgroundColor = "catppuccin-macchiato",
            },
            scratchPad = {
              enabled = false,
              location = nil,
            },
            bo = {
              filetype = "md",
            },
          },
        })
      '';
    };

    # Navic
    navic = {
      package = pkgs.vimPlugins.nvim-navic;
      setup = ''
        require("nvim-navic").setup({
          lsp = {
            auto_attach = true,
          },
          separator = " › ",
          depth_limit = 0,
          safe_output = true,
        })
      '';
    };

    # Navbuddy (depends on navic)
    navbuddy = {
      package = pkgs.vimPlugins.nvim-navbuddy;
      after = ["nvim-navic"];
      setup = ''
        require("nvim-navbuddy").setup({
          lsp = {
            auto_attach = true,
          },
        })
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

    # FFF - File finder with frecency
    fff-nvim = {
      package = pkgs.vimPlugins.fff-nvim.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace lua/fff/core.lua \
              --replace ".. result, vim.log.levels.WARN)" ".. tostring(result), vim.log.levels.WARN)" \
              --replace ".. result, vim.log.levels.ERROR)" ".. tostring(result), vim.log.levels.ERROR)"
          '';
      });
    };

    # Helm-ls plugin for template features
    helm-ls-nvim = {
      package = pkgs.vimPlugins.helm-ls-nvim;
      setup = ''
        require("helm-ls").setup({
          conceal_templates = {
            enabled = true,
          },
          indent_hints = {
            enabled = true,
            only_for_current_line = true,
          },
        })
      '';
    };

    # PR review comments as LSP diagnostics
    prlsp = {
      package = pkgs.vimPlugins.prlsp-nvim;
      setup = ''
        vim.lsp.config.prlsp = {
          cmd = { '${pkgs.prlsp}/bin/prlsp' },
          root_dir = function(bufnr, cb)
            local root = vim.fs.root(bufnr, { '.git' })
            if not root then
              cb(nil)
              return
            end
            vim.system(
              { 'git', '-C', root, 'remote', 'get-url', 'origin' },
              { text = true },
              function(result)
                if result.code == 0 and result.stdout:match('github%.com') then
                  cb(root)
                else
                  cb(nil)
                end
              end
            )
          end,
        }
        vim.lsp.enable('prlsp')

        vim.keymap.set("n", "<leader>gpc", function() require("prlsp").comment_on_line() end, { desc = "PR comment on line" })
        vim.keymap.set("n", "<leader>gpr", function() require("prlsp").reply_on_line() end, { desc = "PR reply on line" })
        vim.keymap.set("n", "<leader>gpt", function() require("prlsp").show_thread() end, { desc = "PR show thread" })
        vim.keymap.set("n", "<leader>gpf", function() require("prlsp").refresh() end, { desc = "PR refresh" })
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
}
