{
  pkgs,
  lib,
  vars,
  inputs,
  ...
}: let
  # Extend lib with nvf's DAG utilities
  nvfLib = inputs.nvf.lib.nvim;
  extendedLib = lib.extend (_: _: {nvim = nvfLib;});
in {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = lib.mkDefault true;
    settings.vim = lib.mkMerge [
      # Base settings
      {
        viAlias = true;
        vimAlias = true;
        globals.editorconfig = true;

        # Theme
        theme = {
          enable = true;
          name = "catppuccin";
          style = "macchiato";
          transparent = true;
          extraConfig = ''
            require("catppuccin").setup({
              flavour = "macchiato",
              transparent_background = true,
              float = {
                transparent = true,
                solid = false,
              },
              show_end_of_buffer = false,
              term_colors = true,
              no_italic = false,
              no_bold = false,
              no_underline = false,
              styles = {
                comments = { "italic" },
                conditionals = { "italic" },
              },
              default_integrations = true,
              integrations = {
                gitsigns = true,
                treesitter = true,
                dap = true,
                dap_ui = true,
                mini = {
                  enabled = true,
                  indentscope_color = "",
                },
              },
            })

            -- Custom LineNr highlights
            vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#403d52", bold = false })
            vim.api.nvim_set_hl(0, "LineNr", { fg = "#c4a7e7", bold = true })
            vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#403d52", bold = false })
          '';
        };
      }

      # Import all module files - they return vim.* attribute sets
      (import ./options.nix {
        lib = extendedLib;
        inherit vars;
      })
      (import ./autocmds.nix {
        lib = extendedLib;
        inherit vars;
      })
      (import ./keymaps.nix {
        lib = extendedLib;
        inherit vars;
      })
      (import ./languages.nix {
        inherit pkgs;
        lib = extendedLib;
        inherit vars;
      })
      (import ./plugins.nix {
        inherit pkgs;
        lib = extendedLib;
        inherit vars;
      })
      (import ./plugins-custom.nix {
        inherit pkgs;
        lib = extendedLib;
        inherit vars;
      })
      (import ./extra-config.nix {
        lib = extendedLib;
        inherit vars;
      })
    ];
  };
}
