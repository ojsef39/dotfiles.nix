{
  pkgs,
  lib,
  ...
}: {
  # nvf pins smart-splits v2, which predates pluggable mux backends.
  lazy.plugins.smart-splits.package = lib.mkForce (pkgs.fetchFromGitHub {
    owner = "smart-splits-nvim";
    repo = "smart-splits.nvim";
    rev = "6a03b298635205802ee1d390826f02414a13290d";
    hash = "sha256-6gB1vSxJposF5MyuoVcbxkp3tlhkueENSruQWDVEGig=";
    name = "smart-splits";
  });

  extraPlugins = {
    # Lets smart-splits.nvim move/resize across kitty windows, as a fallback
    # when not in Rex. Uses kitty remote control (allow_remote_control +
    # listen_on in the kitty module); ctrl+hjkl reach nvim via pass_keys.py.
    smart-splits-backend-kitty = {
      package = pkgs.fetchFromGitHub {
        owner = "smart-splits-nvim";
        repo = "backend-kitty";
        rev = "70665a2228d52c255f3d116a146932f326df3914";
        hash = "sha256-gCi3WYWDxOo/u2M8WbvQ9uGKSSqFqTb1RfruOYuuk4Y=";
        name = "smart-splits-backend-kitty";
      };
      setup = "require('smart-splits-backend-kitty').setup {}";
    };

    # Lets smart-splits.nvim move/resize across Rex panes
    smart-splits-backend-rex = {
      package = pkgs.fetchFromGitHub {
        owner = "rawnly";
        repo = "smart-splits-backend-rex";
        rev = "45785cf5d15dd5e0e6cf25ab9682a146acb93379";
        hash = "sha256-lqLdyVticzh0uv0dX1LBhfep3doRpKuidkp8QbzVG6Y=";
        name = "smart-splits-backend-rex";
      };
      # rex is on PATH via REX_BIN_DIR (see modules/shell/shellInit.fish)
      setup = ''
        require('smart-splits-backend-rex').setup {}

        -- Leave nvim through the rex config's smart_splits_focus action instead
        -- of the backend's own focus script, so it returns to the pane you came
        -- from like ctrl+h/j/k/l in rex. passthrough=false keeps rex from sending
        -- the key straight back into nvim; the action reports {"handled": bool}
        -- like the script did. (Overrides an internal of the pinned backend.)
        local rex_cli = require('smart-splits-backend-rex.rex')
        rex_cli.focus = function(direction, wrap)
          local result = rex_cli.run({ 'do', 'smart_splits_focus', 'direction=' .. direction, 'passthrough=false' })
          if result == nil or result.code ~= 0 then
            return false
          end
          local ok, decoded = pcall(vim.json.decode, result.stdout)
          return ok and type(decoded) == 'table' and decoded.handled == true
        end
      '';
    };

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

    # Lazygit
    lazygit = {
      package = pkgs.vimPlugins.lazygit-nvim;
      setup = ''
        vim.g.lazygit_floating_window_border_chars = { "", "", "", "", "", "", "", "" }
        vim.keymap.set("n", "<leader>gg", function()
          -- Inside Rex, open lazygit as a Rex float (lazygit_float action)
          if os.getenv("REX_SESSION") and vim.fn.executable("rex") == 1 then
            vim.system({ "rex", "do", "lazygit_float" })
            return
          end
          vim.cmd("LazyGit")
        end, { desc = "LazyGit" })
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
        vim.api.nvim_create_autocmd('BufReadPost', {
          callback = function(ev)
            local root = vim.fs.root(ev.buf, { '.git' })
            if not root then return end
            vim.system(
              { 'git', '-C', root, 'remote', '-v' },
              { text = true },
              function(result)
                if result.code == 0 and result.stdout:match('github%.com') then
                  vim.schedule(function()
                    vim.lsp.start({
                      name = 'prlsp',
                      cmd = { '${pkgs.prlsp}/bin/prlsp' },
                      root_dir = root,
                    }, { bufnr = ev.buf })
                  end)
                end
              end
            )
          end,
        })

        vim.keymap.set("n", "<leader>gpc", function() require("prlsp").comment_on_line() end, { desc = "PR comment on line" })
        vim.keymap.set("n", "<leader>gpr", function() require("prlsp").reply_on_line() end, { desc = "PR reply on line" })
        vim.keymap.set("n", "<leader>gpt", function() require("prlsp").show_thread() end, { desc = "PR show thread" })
        vim.keymap.set("n", "<leader>gpf", function() require("prlsp").refresh() end, { desc = "PR refresh" })
      '';
    };
  };
}
