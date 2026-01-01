{...}: {
  # Leader keys and global variables
  globals = {
    mapleader = " ";
    maplocalleader = "\\";
    have_nerd_font = true;
  };

  # All keymaps
  keymaps = [
    # Clear search highlight
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      mode = "n";
    }
    # Redo with U
    {
      key = "U";
      action = "<c-r>";
      mode = "n";
      desc = "Redo";
    }

    # LSP keymaps
    {
      key = "<leader>lD";
      action = "function() vim.diagnostic.setloclist() end";
      mode = "n";
      lua = true;
      desc = "Diagnostic Loclist";
    }
    {
      key = "gi";
      action = "vim.lsp.buf.implementation";
      mode = "n";
      lua = true;
      desc = "Go to Implementation";
    }

    # Conform formatting
    {
      key = "<leader>cF";
      action = "function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end";
      mode = ["n" "v"];
      lua = true;
      desc = "Format Injected Langs";
    }
    {
      key = "<leader>ct";
      action = "function() _G.toggle_conform() end";
      mode = "n";
      lua = true;
      desc = "Toggle Conform";
    }

    # Linting
    {
      key = "<leader>cl";
      action = "function() require('lint').try_lint() end";
      mode = "n";
      lua = true;
      desc = "Lint current buffer";
    }

    # Todo-comments
    {
      key = "<leader>dx";
      action = "function() _G.todo_picker(false) end";
      mode = "n";
      lua = true;
      desc = "Search TODOs";
    }
    {
      key = "<leader>dX";
      action = "function() _G.todo_picker(true) end";
      mode = "n";
      lua = true;
      desc = "Search TODOs (Current File)";
    }
    {
      key = "<leader>dl";
      action = "<cmd>TodoQuickFix<cr>";
      mode = "n";
      desc = "TODO List";
    }
    {
      key = "<leader>dL";
      action = "function() _G.todo_quickfix_current() end";
      mode = "n";
      lua = true;
      desc = "TODO List (Current File)";
    }

    # Mini.nvim
    {
      key = "<leader>bd";
      action = "function() require('mini.bufremove').delete() end";
      mode = "n";
      lua = true;
      desc = "Delete Buffer";
    }
    {
      key = "<leader><space>";
      action = "function() require('mini.pick').registry.fffiles() end";
      mode = "n";
      lua = true;
      desc = "FFF Files";
    }
    {
      key = "<leader>fg";
      action = ''
        function()
          local temp_config = vim.fn.tempname()
          vim.fn.writefile({ '--hidden', '--glob=!.git/*' }, temp_config)
          vim.env.RIPGREP_CONFIG_PATH = temp_config
          require('mini.pick').builtin.grep_live()
        end
      '';
      mode = "n";
      lua = true;
      desc = "Live Grep";
    }
    {
      key = "<leader>lo";
      action = "function() require('mini.extra').pickers.lsp({ scope = 'workspace_symbol' }) end";
      mode = "n";
      lua = true;
      desc = "Workspace Symbols";
    }
    {
      key = "<leader>ls";
      action = "<cmd>Navbuddy<cr>";
      mode = "n";
      desc = "Navbuddy";
      silent = true;
    }
    {
      key = "<leader>ld";
      action = "function() require('mini.extra').pickers.diagnostic() end";
      mode = "n";
      lua = true;
      desc = "Diagnostics";
    }
    {
      key = "<leader>gi";
      action = "function() require('mini.extra').pickers.git_hunks() end";
      mode = "n";
      lua = true;
      desc = "Git Hunks";
    }
    {
      key = "<leader>bf";
      action = "function() require('mini.pick').builtin.buffers() end";
      mode = "n";
      lua = true;
      desc = "Buffers";
    }
    {
      key = "<leader>ch";
      action = "function() require('mini.extra').pickers.history() end";
      mode = "n";
      lua = true;
      desc = "Command History";
    }
    {
      key = "<leader>mk";
      action = "function() require('mini.extra').pickers.keymaps() end";
      mode = "n";
      lua = true;
      desc = "Keymaps";
    }
    {
      key = "<leader>ms";
      action = "function() require('mini.extra').pickers.marks() end";
      mode = "n";
      lua = true;
      desc = "Marks";
    }

    # Navigation
    {
      key = "<c-u>";
      action = "<c-u>zz";
      mode = "n";
      desc = "Scroll up half screen";
    }
    {
      key = "<c-d>";
      action = "<c-d>zz";
      mode = "n";
      desc = "Scroll down half screen";
    }
    {
      key = "n";
      action = "nzzzv";
      mode = "n";
      desc = "Next search result";
    }
    {
      key = "N";
      action = "Nzzzv";
      mode = "n";
      desc = "Previous search result";
    }

    # Editing
    {
      key = "<leader>d";
      action = ''"_d'';
      mode = "v";
      desc = "Delete without clipboard";
    }
    {
      key = "<leader>s";
      action = '':%s/\<<c-r><c-w>\>/<c-r><c-w>/gc<left><left><left>'';
      mode = "n";
      desc = "Search and replace word";
    }
    {
      key = "<leader>s";
      action = ''"zy:%s/\C<c-r>z/<c-r>z/gc<left><left><left>'';
      mode = "v";
      desc = "Search and replace selection";
    }

    # Buffer navigation
    {
      key = "<Tab>";
      action = ":bnext<cr>";
      mode = "n";
      silent = true;
    }
    {
      key = "<S-Tab>";
      action = ":bprev<cr>";
      mode = "n";
      silent = true;
    }

    # Tab management
    {
      key = "<leader>t";
      action = ":tabnew<cr>";
      mode = "n";
      desc = "New Tab";
      silent = true;
    }
    {
      key = "<leader>x";
      action = ":tabclose<cr>";
      mode = "n";
      desc = "Close Tab";
      silent = true;
    }
    {
      key = "<leader>j";
      action = ":tabprevious<cr>";
      mode = "n";
      desc = "Prev Tab";
      silent = true;
    }
    {
      key = "<leader>k";
      action = ":tabnext<cr>";
      mode = "n";
      desc = "Next Tab";
      silent = true;
    }

    # Window splits
    {
      key = "<leader>wh";
      action = "<C-w>v<C-w>h";
      mode = "n";
      desc = "Split Left";
      silent = true;
    }
    {
      key = "<leader>wj";
      action = "<C-w>s";
      mode = "n";
      desc = "Split Down";
      silent = true;
    }
    {
      key = "<leader>wk";
      action = "<C-w>s<C-w>k";
      mode = "n";
      desc = "Split Up";
      silent = true;
    }
    {
      key = "<leader>wl";
      action = "<C-w>v";
      mode = "n";
      desc = "Split Right";
      silent = true;
    }
    {
      key = "<leader>wv";
      action = "<C-w>v";
      mode = "n";
      desc = "Split Vertical";
      silent = true;
    }
    {
      key = "<leader>ws";
      action = "<C-w>s";
      mode = "n";
      desc = "Split Horizontal";
      silent = true;
    }
    {
      key = "<leader>wc";
      action = "<C-w>c";
      mode = "n";
      desc = "Close Split";
      silent = true;
    }
    {
      key = "<leader>wo";
      action = "<C-w>o";
      mode = "n";
      desc = "Close Other Splits";
      silent = true;
    }
    {
      key = "<leader>wx";
      action = "<C-w>x";
      mode = "n";
      desc = "Exchange Splits";
      silent = true;
    }

    # Visual mode - move lines
    {
      key = "<S-Up>";
      action = ":m '<-2<CR>gv=gv";
      mode = "v";
      desc = "Move selection up";
      silent = true;
    }
    {
      key = "<S-Down>";
      action = ":m '>+1<CR>gv=gv";
      mode = "v";
      desc = "Move selection down";
      silent = true;
    }

    # Visual mode - indent
    {
      key = "<";
      action = "<gv";
      mode = "v";
      desc = "Indent left";
      silent = true;
    }
    {
      key = ">";
      action = ">gv";
      mode = "v";
      desc = "Indent right";
      silent = true;
    }

    # Quick marks
    {
      key = "<C-1>";
      action = "'A";
      mode = "n";
      desc = "Jump to Mark A";
    }
    {
      key = "<C-2>";
      action = "'B";
      mode = "n";
      desc = "Jump to Mark B";
    }
    {
      key = "<C-3>";
      action = "'C";
      mode = "n";
      desc = "Jump to Mark C";
    }
    {
      key = "<C-4>";
      action = "'D";
      mode = "n";
      desc = "Jump to Mark D";
    }
    {
      key = "<C-5>";
      action = "'E";
      mode = "n";
      desc = "Jump to Mark E";
    }

    # Toggle boolean
    {
      key = "yt";
      action = "function() return package.loaded['_toggle_bool']() end";
      mode = "n";
      lua = true;
      desc = "Toggle boolean value";
    }

    # Duplicate and comment
    {
      key = "yc";
      action = "function() vim.api.nvim_feedkeys('yygccp', 'm', false) end";
      mode = "n";
      lua = true;
      desc = "Duplicate and comment line";
      silent = true;
    }

    # Undotree
    {
      key = "<leader>cu";
      action = "<cmd>UndotreeToggle<cr>";
      mode = "n";
      desc = "Undotree";
      silent = true;
    }

    # No Neck Pain
    {
      key = "<leader>cn";
      action = "<cmd>NoNeckPain<cr>";
      mode = "n";
      desc = "Toggle No Neck Pain";
      silent = true;
    }

    # Noice notification history
    {
      key = "<leader>n";
      action = ":NoiceHistory<cr>";
      mode = "n";
      desc = "Show Notification History";
      silent = true;
    }

    # Markdown preview
    {
      key = "<leader>mm";
      action = ":MarkdownPreviewToggle<cr>";
      mode = ["n" "v"];
      desc = "Toggle Markdown Preview";
      silent = true;
    }
    {
      key = "<leader>mp";
      action = ":MarkdownPreview<cr>";
      mode = ["n" "v"];
      desc = "Start Markdown Preview";
      silent = true;
    }
    {
      key = "<leader>ms";
      action = ":MarkdownPreviewStop<cr>";
      mode = ["n" "v"];
      desc = "Stop Markdown Preview";
      silent = true;
    }

    # DAP custom keymaps
    {
      key = "<leader>Da";
      action = ":DapNew<cr>";
      mode = "n";
      desc = "Debug New";
    }
    {
      key = "<leader>D?";
      action = "function() require('dapui').eval(nil, { enter = true }) end";
      mode = "n";
      lua = true;
      desc = "Debug Eval";
    }

    # Gitsigns full blame panel
    {
      key = "<leader>gb";
      action = "<cmd>Gitsigns blame<cr>";
      mode = "n";
      desc = "Git Blame";
      silent = true;
    }

    # Gitlinker
    {
      key = "<leader>go";
      action = "function() require('gitlinker').link() end";
      mode = ["n" "v"];
      lua = true;
      desc = "Git Browse (open in browser)";
      silent = true;
    }
    {
      key = "<leader>gy";
      action = "function() require('gitlinker').link({ action = require('gitlinker.actions').clipboard }) end";
      mode = ["n" "v"];
      lua = true;
      desc = "Git Copy URL";
      silent = true;
    }

    # Yazi (custom keymaps that handle special buffers like ministarter)
    {
      key = "<leader>e";
      action = "function() _G.yazi_toggle_smart() end";
      mode = "n";
      lua = true;
      desc = "Resume last yazi session";
      silent = true;
    }
    {
      key = "<leader>E";
      action = "function() _G.yazi_open_smart() end";
      mode = "n";
      lua = true;
      desc = "Open yazi at current file";
      silent = true;
    }
  ];
}
