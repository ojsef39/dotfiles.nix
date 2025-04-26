return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-j>",
            accept_word = "<C-l>",
            accept_line = "<C-k>",
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<C-h>",
          },
        },
        filetypes = {
          ["*"] = true, -- Enable for ALL filetypes by default
          -- Only disable specific filetypes as needed
          help = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
        },
        -- Prevent Copilot from attaching to sensitive files like .env
        should_attach = function(_, bufname)
          if string.match(bufname, "%.env") then
            return false
          end

          return true
        end,
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    cmd = "CopilotChat",
    build = function()
      -- Only build on Mac/Linux
      if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
        return "make tiktoken"
      end
    end,
    opts = {
      -- Set default model
      model = "claude-3.7-sonnet",
      mappings = {
        -- Disable Tab for completion by assigning it to a different key
        complete = {
          insert = "",
        },
      },
    },
    -- Chat keybindings config
    keys = {
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>aa",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ax",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({
            prompt = "Quick Chat: ",
          }, function(input)
            if input and input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "Prompt Actions (CopilotChat)",
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
}
