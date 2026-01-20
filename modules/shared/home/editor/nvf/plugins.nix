{
  lib,
  vars,
  pkgs,
  ...
}: {
  # Completion with blink-cmp
  autocomplete.blink-cmp = {
    enable = true;
    setupOpts = {
      keymap = {
        preset = "super-tab";
      };
      sources = {
        default = ["lsp" "path" "snippets" "buffer"];
      };
      completion = {
        ghost_text = {enabled = true;};
        menu = {
          border = "rounded";
          draw = {
            columns = lib.generators.mkLuaInline ''
              {
                { "kind_icon", "label", "label_description", gap = 1 },
                { "kind" }
              }
            '';
            components = {
              kind_icon = {
                text = lib.generators.mkLuaInline ''
                  function(ctx)
                    local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                    return kind_icon
                  end
                '';
                highlight = lib.generators.mkLuaInline ''
                  function(ctx)
                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                    return hl
                  end
                '';
              };
              kind = {
                highlight = lib.generators.mkLuaInline ''
                  function(ctx)
                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                    return hl
                  end
                '';
              };
            };
          };
        };
        documentation = {
          window = {border = "rounded";};
        };
      };
      signature = {
        enabled = true;
        window = {border = "rounded";};
      };
    };
  };

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

  # Git
  git = {
    enable = true;
    gitsigns = {
      enable = true;
      codeActions.enable = false;
      mappings = {
        previewHunk = "<leader>gp";
        toggleBlame = "<leader>gt";
        blameLine = null;
        diffThis = "<leader>gd";

        diffProject = "<leader>gD";
        resetBuffer = "<leader>gR";
        resetHunk = "<leader>gr";
        stageBuffer = "<leader>gS";
        stageHunk = "<leader>gs";
        undoStageHunk = "<leader>gu";
        toggleDeleted = "<leader>gx";

        nextHunk = "]c";
        previousHunk = "[c";
      };
    };
    git-conflict = {
      enable = true;
      mappings = {
        ours = "<leader>gh";
        theirs = "<leader>gl";
        both = "<leader>ga";
        none = "<leader>g0";
        nextConflict = "]x";
        prevConflict = "[x";
      };
    };
    gitlinker-nvim = {
      enable = true;
      setupOpts = {
        opts = {
          add_current_line_on_normal_mode = true;
          action_callback = "require('gitlinker.actions').open_in_browser";
          print_url = true;
        };
        callbacks = vars.git.callbacks or {};
      };
    };
  };

  # Treesitter
  treesitter = {
    enable = true;
    fold = true;

    highlight.enable = true;
    indent.enable = true;

    grammars = lib.mkAfter [pkgs.vimPlugins.nvim-treesitter.builtGrammars.swift];

    textobjects = {
      enable = true;
      setupOpts = {
        move = {
          enable = true;
          goto_next_start = {
            "]f" = "@function.outer";
            "]c" = "@class.outer";
          };
          goto_next_end = {
            "]F" = "@function.outer";
            "]C" = "@class.outer";
          };
          goto_previous_start = {
            "[f" = "@function.outer";
            "[c" = "@class.outer";
          };
          goto_previous_end = {
            "[F" = "@function.outer";
            "[C" = "@class.outer";
          };
        };
      };
    };
  };

  comments.comment-nvim.enable = true;

  # TODO/Notes
  notes = {
    todo-comments = {
      enable = true;
      mappings = {
        # Disable nvf defaults - using custom keymaps at <leader>dx/dX/dl/dL instead
        quickFix = null;
        telescope = null;
        trouble = null;
      };
    };
  };

  # UI plugins
  ui = {
    noice = {
      enable = true;
      setupOpts = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = false;
          lsp_doc_border = false;
        };
        notify = {
          enabled = true;
        };
      };
    };

    # Breadcrumbs - disabled, using custom navic + navbuddy in plugins-custom.nix
    # breadcrumbs = {
    #   enable = false;
    # };
  };

  # Utility plugins
  utility = {
    undotree.enable = true;
    diffview-nvim.enable = true;

    preview.markdownPreview = {
      enable = true;
      filetypes = ["markdown" "rst"];
    };

    smart-splits = {
      enable = true;
      keymaps = {
        # Resizing
        resize_left = "<A-h>";
        resize_down = "<A-j>";
        resize_up = "<A-k>";
        resize_right = "<A-l>";
        # Moving
        move_cursor_left = "<C-h>";
        move_cursor_down = "<C-j>";
        move_cursor_up = "<C-k>";
        move_cursor_right = "<C-l>";
        move_cursor_previous = "<C-\\>";
        swap_buf_left = "<leader>wH";
        swap_buf_down = "<leader>wJ";
        swap_buf_up = "<leader>wK";
        swap_buf_right = "<leader>wL";
      };
    };

    yazi-nvim = {
      enable = true;
      mappings = {
        # Disable default mappings - using custom ones that handle special buffers
        openYazi = null;
        yaziToggle = null;
        openYaziDir = null;
      };
      setupOpts = {
        open_for_directories = false;
        yazi_floating_window_border = "rounded";
        env = {
          SKIP_FF = "1";
        };
        future_features = {
          use_cwd_file = true; # Store last directory for resume behavior
        };
      };
    };
  };

  # DAP (debugging)
  debugger = {
    nvim-dap = {
      enable = true;
      ui = {
        enable = true;
        autoStart = true;
      };
      mappings = {
        continue = "<leader>Dc";
        toggleBreakpoint = "<leader>Db";
        stepOver = "<leader>Dn";
        stepInto = "<leader>Di";
        stepOut = "<leader>Do";
        goDown = "<leader>Dd";
        terminate = "<leader>Ds";
        toggleDapUI = "<leader>Dt";

        # Disable nvf's <leader>dg* defaults
        runToCursor = null;
        stepBack = null;
        hover = null;
        restart = null;
        runLast = null;
        goUp = null;
        toggleRepl = null;
      };
      sources = {
        dap-config = builtins.readFile ./lua/dap-config.lua;
      };
    };
  };

  # Formatter
  formatter = {
    conform-nvim = {
      enable = true;
      setupOpts = {
        default_format_opts = {
          timeout_ms = 3000;
          async = false;
          quiet = false;
        };
        formatters_by_ft = {
          # Languages with custom formatters not supported by nvf
          "markdown.mdx" = ["prettier" "markdownlint-cli2"];
          dockerfile = ["dockerfmt"];
          fish = ["fish_indent"];
          go = ["gofumpt" "goimports-reviser"]; # nvf doesn't support goimports-reviser
          graphql = ["prettier"];
          handlebars = ["prettier"];
          html = ["prettier"]; # nvf only supports superhtml
          json = ["prettier"]; # nvf only supports jsonfmt
          json5 = ["prettier"];
          jsonc = ["prettier"];
          less = ["prettier"];
          markdown = ["prettier" "markdownlint-cli2"]; # nvf has deno_fmt, we want prettier + markdownlint
          scss = ["prettier"];
          swift = ["swift-format"];
          terraform = ["terraform_fmt"];
          vue = ["prettier"];
          yaml = ["prettier"];
          # Note: python, nix, lua, sh, typescript, javascript, rust, css are handled in languages.nix
        };
        format_on_save = {
          lsp_fallback = true;
          timeout_ms = 3000;
        };
        format_after_save = {
          lsp_fallback = true;
        };
        log_level = lib.generators.mkLuaInline "vim.log.levels.ERROR";
        notify_on_error = true;
        notify_no_formatters = true;
        formatters = {
          # Only define formatters for languages not handled by nvf language modules
          injected.options.ignore_errors = true;

          # Go formatters (nvf doesn't support goimports-reviser)
          "goimports-reviser" = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#goimports-reviser" "--"];
          };
          gofumpt = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#gofumpt" "--"];
          };

          # Markdown formatters
          "markdownlint-cli2" = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#markdownlint-cli2" "--"];
          };
          markdownlint = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#markdownlint-cli" "--"];
          };

          # Other formatters not in nvf
          dockerfmt = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#dockerfmt" "--"];
          };
          fish_indent = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#fish" "--" "fish_indent"];
          };
          prettier = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#nodePackages.prettier" "--"];
          };
          "swift-format" = {
            command = "nix";
            stdin = true;
            args = ["run" "--impure" "nixpkgs#swift-format" "--" "format" "--assume-filename" "$FILENAME"];
          };
          terraform_fmt = {
            command = "nix";
            "inherit" = true;
            prepend_args = ["run" "--impure" "nixpkgs#terraform" "--" "fmt" "-"];
            stdin = true;
            env = {NIXPKGS_ALLOW_UNFREE = "1";};
          };
          # Note: black, isort, alejandra, stylua, shfmt, rustfmt are handled in languages.nix
        };
      };
    };
  };

  # Diagnostics
  diagnostics = {
    nvim-lint = {
      enable = true;
      lint_after_save = false; # Using custom autocmds in autocmds.nix instead

      # Custom lint function to add actionlint for GitHub Actions workflows
      lint_function = lib.generators.mkLuaInline ''
        function(buf)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          local names = require("lint").linters_by_ft[ft]

          if not names or vim.tbl_isempty(names) then
            return
          end

          -- Add actionlint for GitHub Actions workflow files
          if ft == "yaml" then
            local filepath = vim.api.nvim_buf_get_name(buf)
            if filepath:match("%.github/workflows/.*%.ya?ml$") then
              names = vim.deepcopy(names)
              table.insert(names, "actionlint")
            end
          end

          require("lint").try_lint(names, { bufnr = buf })
        end
      '';

      linters_by_ft = {
        bash = ["shellcheck"];
        css = ["stylelint"];
        dockerfile = ["hadolint"];
        fish = ["fish"];
        go = ["golangcilint"];
        html = ["htmlhint"];
        javascript = ["eslint"];
        javascriptreact = ["eslint"];
        json = ["jsonlint"];
        json5 = ["jsonlint"];
        jsonc = ["jsonlint"];
        less = ["stylelint"];
        lua = ["luacheck"];
        markdown = ["markdownlint"];
        "markdown.mdx" = ["markdownlint"];
        nix = ["deadnix" "statix"];
        python = ["pylint"];
        rust = ["clippy"];
        scss = ["stylelint"];
        sh = ["shellcheck"];
        swift = ["swift-format"];
        terraform = ["tflint"];
        typescript = ["eslint"];
        typescriptreact = ["eslint"];
        vue = ["eslint"];
        yaml = ["yamllint"];
        zsh = ["shellcheck"];
      };
      linters = {
        actionlint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#actionlint" "--" "-format" "{{json .}}"];
        };

        clippy = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#cargo" "--"];
        };

        deadnix = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#deadnix" "--"];
        };

        eslint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#eslint" "--"];
        };

        fish = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#fish" "--"];
        };

        golangcilint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#golangci-lint" "--"];
        };

        hadolint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#hadolint" "--"];
        };

        htmlhint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#htmlhint" "--"];
        };

        jsonlint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#nodePackages.jsonlint" "--"];
        };

        luacheck = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#lua54Packages.luacheck" "--"];
        };

        markdownlint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#markdownlint-cli" "--"];
        };

        pylint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#pylint" "--"];
        };

        shellcheck = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#shellcheck" "--"];
        };

        statix = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#statix" "--"];
        };

        stylelint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#stylelint" "--"];
        };

        "swift-format" = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#swift-format" "--" "lint" "--strict"];
        };

        tflint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#tflint" "--"];
        };

        yamllint = {
          cmd = "nix";
          args = ["run" "--impure" "nixpkgs#yamllint" "--"];
          stdin = false;
          parser = lib.generators.mkLuaInline ''
            require('lint.parser').from_pattern(
              '.-:(%d+):(%d+): %[(.+)%] (.+) %((.+)%)',
              { 'lnum', 'col', 'severity', 'message', 'code' },
              { ['error'] = vim.diagnostic.severity.ERROR, ['warning'] = vim.diagnostic.severity.WARN },
              { ['source'] = 'yamllint' }
            )
          '';
        };
      };
    };
  };

  # Mini.nvim modules
  mini = {
    # Simple text objects
    ai = {
      enable = true;
    };

    # Surround text objects
    surround = {
      enable = true;
    };

    # Smart buffer deletion
    bufremove = {
      enable = true;
    };

    # Highlight word under cursor
    cursorword = {
      enable = true;
    };

    # Icon provider
    icons = {
      enable = true;
    };

    # Extra utilities
    extra = {
      enable = true;
    };

    # Move selections
    move = {
      enable = true;
      setupOpts = {
        mappings = {
          left = "<S-h>";
          right = "<S-l>";
          down = "<S-j>";
          up = "<S-k>";
        };
      };
    };

    # Hex color highlighting
    hipatterns = {
      enable = true;
      setupOpts = {
        highlighters = {
          hex_color = lib.generators.mkLuaInline "require('mini.hipatterns').gen_highlighter.hex_color()";
        };
      };
    };

    # Which-key replacement
    clue = {
      enable = true;
      setupOpts = {
        triggers = [
          {
            mode = "n";
            keys = "<Leader>";
          }
          {
            mode = "x";
            keys = "<Leader>";
          }
          {
            mode = "i";
            keys = "<C-x>";
          }
          {
            mode = "n";
            keys = "g";
          }
          {
            mode = "x";
            keys = "g";
          }
          {
            mode = "n";
            keys = "'";
          }
          {
            mode = "n";
            keys = "`";
          }
          {
            mode = "x";
            keys = "'";
          }
          {
            mode = "x";
            keys = "`";
          }
          {
            mode = "n";
            keys = ''"'';
          }
          {
            mode = "x";
            keys = ''"'';
          }
          {
            mode = "i";
            keys = "<C-r>";
          }
          {
            mode = "c";
            keys = "<C-r>";
          }
          {
            mode = "n";
            keys = "<C-w>";
          }
          {
            mode = "n";
            keys = "z";
          }
          {
            mode = "x";
            keys = "z";
          }
        ];
        clues = lib.generators.mkLuaInline ''
          vim.list_extend({
            -- Custom leader key descriptions
            { mode = "n", keys = "<Leader>b", desc = "Buffer" },
            { mode = "n", keys = "<Leader>c", desc = "Command" },
            { mode = "n", keys = "<Leader>d", desc = "TODOs" },
            { mode = "n", keys = "<Leader>D", desc = "Debug/DAP" },
            { mode = "n", keys = "<Leader>f", desc = "Find" },
            { mode = "n", keys = "<Leader>g", desc = "Git" },
            { mode = "n", keys = "<Leader>j", desc = "Previous Tab" },
            { mode = "n", keys = "<Leader>k", desc = "Next Tab" },
            { mode = "n", keys = "<Leader>l", desc = "LSP" },
            { mode = "n", keys = "<Leader>m", desc = "Markdown/Marks" },
            { mode = "n", keys = "<Leader>s", desc = "Search/Symbols" },
            { mode = "n", keys = "<Leader>t", desc = "Tabs/Trouble" },
            { mode = "n", keys = "<Leader>w", desc = "Windows" },
            { mode = "n", keys = "<Leader>x", desc = "Close Tab" },
            { mode = "v", keys = "<Leader>d", desc = "Delete (no clipboard)" },
          }, vim.iter({
            require('mini.clue').gen_clues.builtin_completion(),
            require('mini.clue').gen_clues.g(),
            require('mini.clue').gen_clues.marks(),
            require('mini.clue').gen_clues.registers(),
            require('mini.clue').gen_clues.windows(),
            require('mini.clue').gen_clues.z(),
          }):flatten():totable())
        '';
        window = {
          delay = 200;
        };
      };
    };

    # Start screen
    starter = {
      enable = true;
      setupOpts = {
        items = lib.generators.mkLuaInline "require('mini.starter').sections.builtin_actions()";
        content_hooks = lib.generators.mkLuaInline ''
          { require('mini.starter').gen_hook.aligning('center', 'center') }
        '';
        footer = "";
        silent = true;
      };
    };

    # Picker (telescope alternative)
    pick = {
      enable = true;
      setupOpts = {
        mappings = {
          choose_marked = "<C-q>";
          paste = "<C-r>";
        };
        window = {
          config = lib.generators.mkLuaInline ''
            function()
              local picker_width = math.min(120, math.floor(vim.o.columns * 0.8))
              local picker_height = math.min(30, math.floor(vim.o.lines * 0.6))
              return {
                anchor = "SW",
                col = math.floor((vim.o.columns - picker_width) / 2),
                row = vim.o.lines - 3,
                width = picker_width,
                height = picker_height,
                relative = "editor",
              }
            end
          '';
          prompt_prefix = " ";
        };
        options = {
          use_cache = true;
        };
      };
    };

    # Statusline (custom config in separate file)
    statusline = {
      enable = true;
    };
  };
}
