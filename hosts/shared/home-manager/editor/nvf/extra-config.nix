{lib, ...}: let
  inherit (lib.nvim.dag) entryAnywhere;

  # Automatically discover all .lua files in the extra directory
  extraLuaDir = ./lua/extra;
  extraLuaFiles =
    map (file: extraLuaDir + "/${file}")
    (builtins.filter (file: lib.hasSuffix ".lua" file)
      (builtins.attrNames (builtins.readDir extraLuaDir)));
in {
  # Additional Lua configuration for extra features
  inherit extraLuaFiles;

  luaConfigRC = {
    # Additional configuration for init.lua
    globals = entryAnywhere (builtins.readFile ./lua/globals.lua);
    extra-config = entryAnywhere ''
      vim.opt.isfname:append("@-@")

      -- Disable netrw for yazi
      vim.g.loaded_netrwPlugin = 1

      -- Yazi wrappers to handle special buffers (ministarter, etc)

      -- Resume last yazi session (toggle/resume behavior)
      -- Use the :Yazi toggle command instead of Lua API
      _G.yazi_toggle_smart = function()
        vim.cmd("Yazi toggle")
      end

      -- Open yazi at current file location
      _G.yazi_open_smart = function()
        local bufname = vim.fn.expand('%')

        -- If current buffer is a special buffer (contains ://), open at cwd
        if bufname:match('://') then
          vim.cmd("Yazi cwd")
        else
          -- Open at current file location
          vim.cmd("Yazi")
        end
      end

      -- Additional vim options
      vim.opt.shortmess:remove("S")
      vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

      -- Undotree configuration
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_RelativeTimestamp = 1
      vim.g.undotree_DiffpanelHeight = 10
    '';
  };
}
