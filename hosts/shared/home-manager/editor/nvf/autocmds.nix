{
  lib,
  vars,
  ...
}: let
  inherit (lib.nvim.dag) entryAnywhere;
in {
  # Autocmds for filetype-specific settings
  autocmds = [
    # Indent-based folding for specific filetypes
    {
      event = ["FileType"];
      pattern = ["yaml" "yml" "nix" "python"];
      callback = lib.generators.mkLuaInline ''
        function()
          vim.opt_local.foldmethod = "indent"
        end
      '';
    }
    # Smaller indentation for specific filetypes
    {
      event = ["FileType"];
      pattern = ["helm" "nix" "json" "jsonc" "json5"];
      callback = lib.generators.mkLuaInline ''
        function()
          vim.opt_local.tabstop = 2
          vim.opt_local.softtabstop = 2
          vim.opt_local.shiftwidth = 2
        end
      '';
    }
    # Highlight on yank
    {
      event = ["TextYankPost"];
      pattern = ["*"];
      callback = lib.generators.mkLuaInline ''
        function()
          vim.highlight.on_yank({ higroup = "Visual", priority = 250 })
        end
      '';
    }
  ];

  # Filetype associations (helm detection) and helper functions
  luaConfigRC.pre-config = entryAnywhere ''
    vim.filetype.add({
      pattern = {
        [".*%.base"] = "yaml",
        [".*/templates/.*%.yaml"] = "helm",
        [".*/templates/.*%.yml"] = "helm",
        [".*/templates/.*%.tpl"] = "helm",
        [".*values.*%.yaml"] = "helm",
        [".*values.*%.yml"] = "helm",
        [".*/.*values.*/.*%.yaml"] = "helm",
        [".*/.*values.*/.*%.yml"] = "helm",
        ["Chart%.yaml"] = "helm",
        ["Chart%.yml"] = "helm",
      },
    })

    -- Per-project shada file support
    local workspace_path = vim.fn.getcwd()
    local cache_dir = vim.fn.stdpath("data")
    local unique_id = vim.fn.fnamemodify(workspace_path, ":t") .. "_" .. vim.fn.sha256(workspace_path):sub(1, 8)
    local shadafile = cache_dir .. "/myshada/" .. unique_id .. ".shada"
    vim.opt.shadafile = shadafile

    -- Global variables from your config
    vim.g.projects_dir = vim.env.HOME .. "/${vars.git.ghq or "CodeProjects"}"
    vim.g.nix_dir = "${vars.git.nix or "~/nix-base"}"

    -- Toggle boolean function
    local toggle_bool = function()
      local word = vim.fn.expand("<cword>")
      local line = vim.fn.getline(".")
      local start_pos = vim.fn.searchpos("\\<" .. word .. "\\>", "bcnW", vim.fn.line("."))
      local end_pos = vim.fn.searchpos("\\<" .. word .. "\\>", "cenW", vim.fn.line("."))

      if start_pos[1] == 0 or start_pos[2] == 0 or end_pos[1] == 0 or end_pos[2] == 0 then
        print("No boolean word found under cursor")
        return
      end

      local replacement = ""
      if word == "true" then
        replacement = "false"
      elseif word == "false" then
        replacement = "true"
      elseif word == "True" then
        replacement = "False"
      elseif word == "False" then
        replacement = "True"
      else
        print("Word under cursor is not a boolean value")
        return
      end

      local new_line = string.sub(line, 1, start_pos[2] - 1) .. replacement .. string.sub(line, end_pos[2] + 1)
      vim.fn.setline(".", new_line)
      vim.fn.cursor(vim.fn.line("."), start_pos[2])
    end

    -- Export toggle_bool for keymaps
    package.loaded['_toggle_bool'] = toggle_bool
  '';
}
