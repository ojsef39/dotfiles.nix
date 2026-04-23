{
  pkgs,
  lib,
  ...
}: {
  # LSP configuration
  lsp = {
    enable = true;
    formatOnSave = true;
    lspkind.enable = true;
    lightbulb.enable = pkgs.stdenv.isDarwin;
    lspSignature.enable = false; # Conflicts with blink-cmp

    servers = {
      jsonls = {
        settings = {
          json = {
            schemas = lib.generators.mkLuaInline "require('schemastore').json.schemas()";
            validate.enable = true;
          };
        };
      };
      nixd = {
        settings = {
          nixd = {
            nixpkgs.expr = "import <nixpkgs> {}";
            formatting.command = ["${pkgs.alejandra}/bin/alejandra"];
          };
        };
      };
    };

    mappings = {
      # Document/workspace symbols
      listDocumentSymbols = "<leader>lO";
      listWorkspaceSymbols = "<leader>lo";

      # Code actions and refactoring
      codeAction = "ca";
      renameSymbol = "<space>cr";

      # Navigation
      hover = "K";
      goToDeclaration = "gD";
      goToDefinition = "gd";

      # Diagnostics
      nextDiagnostic = "]d";
      previousDiagnostic = "[d";

      addWorkspaceFolder = null;
      documentHighlight = null;
      format = null;
      goToType = null;
      listImplementations = null;
      listReferences = null;
      listWorkspaceFolders = null;
      openDiagnosticFloat = null;
      removeWorkspaceFolder = null;
      signatureHelp = null;
      toggleFormatOnSave = null;
    };
    lspconfig = {
      enable = true;
      sources = {
        # jsonls provides schema completions/hover for json5 files but its validator
        # doesn't understand JSON5 syntax (trailing commas, unquoted keys, etc.).
        # Disable its diagnostic namespace for json5 buffers on attach — works for
        # both push (publishDiagnostics) and pull (textDocument/diagnostic) models.
        jsonls-json5-diag = ''
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if not client or client.name ~= "jsonls" then return end
              local ok, ft = pcall(vim.api.nvim_get_option_value, "filetype", { buf = args.buf })
              if not ok or ft ~= "json5" then return end
              -- disable push diagnostics namespace
              vim.diagnostic.enable(false, {
                bufnr = args.buf,
                ns_id = vim.lsp.diagnostic.get_namespace(args.data.client_id),
              })
              -- disable pull diagnostics namespace (nvim 0.10.1+)
              local pull_ok, pull_ns = pcall(vim.lsp.diagnostic.get_namespace, args.data.client_id, true)
              if pull_ok then
                vim.diagnostic.enable(false, { bufnr = args.buf, ns_id = pull_ns })
              end
            end,
          })
        '';
        sourcekit = ''
          vim.lsp.config.sourcekit = {
            cmd = { '${pkgs.sourcekit-lsp}/bin/sourcekit-lsp' },
            filetypes = { 'swift', 'objective-c', 'objective-cpp' },
            root_markers = { 'Package.swift', '*.xcodeproj', '*.xcworkspace', '.git' },
          }
          vim.lsp.enable('sourcekit')
        '';
      };
    };
  };

  # Language configurations
  languages = {
    enableFormat = true;
    enableTreesitter = true;

    # Go - with gopls and delve (formatting handled in plugins.nix due to goimports-reviser)
    go = {
      enable = true;
      lsp = {
        enable = true;
        servers = ["gopls"];
      };
      treesitter.enable = true;
      dap = {
        enable = true;
        debugger = "delve";
      };
      format.enable = false; # Using custom conform config for goimports-reviser
    };

    # Nix - with nixd and alejandra
    nix = {
      enable = true;
      lsp = {
        enable = true;
        servers = ["nixd"];
      };
      treesitter.enable = true;
      format = {
        enable = true;
        type = ["alejandra"];
      };
    };

    # Rust - with rust-analyzer and rustfmt
    rust = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      dap.enable = true;
      format = {
        enable = true;
        type = ["rustfmt"];
      };
    };

    # TypeScript/JavaScript - with ts_ls and prettier
    typescript = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format = {
        enable = true;
        type = ["prettier"];
      };
    };

    # Python - with pyright, isort and black
    python = {
      enable = true;
      lsp = {
        enable = true;
        servers = ["pyright"];
      };
      treesitter.enable = true;
      dap = {
        enable = true;
        debugger = "debugpy";
      };
      format = {
        enable = true;
        type = [
          "black"
          "isort"
        ];
      };
    };

    # Bash - with bash-language-server
    bash = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format = {
        enable = true;
        type = ["shfmt"];
      };
    };

    # Lua
    lua = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format = {
        enable = true;
        type = ["stylua"];
      };
    };

    # YAML
    yaml = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };

    # HTML
    html = {
      enable = true;
      treesitter.enable = true;
    };

    # CSS - with prettier
    css = {
      enable = true;
      treesitter.enable = true;
      format = {
        enable = true;
        type = ["prettier"];
      };
    };

    # Terraform
    terraform = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };

    # Markdown
    markdown = {
      enable = true;
      treesitter.enable = true;
      extensions = {
        markview-nvim = {
          enable = true;
          setupOpts = {
            preview = {
              icon_provider = "mini";
            };
          };
        };
      };
    };

    # C/C++
    clang = {
      enable = true;
      lsp = {
        enable = true;
        servers = ["clangd"];
      };
      treesitter.enable = true;
    };

    # Helm
    helm = {
      enable = true;
      lsp = {
        enable = true;
        servers = ["helm-ls"];
      };
      treesitter.enable = true;
    };

    # JSON
    json = {
      enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      format.enable = false; # Using prettier via conform
    };
  };
}
