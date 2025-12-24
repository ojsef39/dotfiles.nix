local dap = require("dap")
local sign = vim.fn.sign_define

-- DAP sign definitions
sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })

-- Go (delve) with remote mode support
dap.adapters.delve = function(callback, config)
  if config.mode == "remote" and config.request == "attach" then
    callback({
      type = "server",
      host = config.host or "127.0.0.1",
      port = config.port or "38697",
    })
  else
    callback({
      type = "server",
      port = "${port}",
      executable = {
        command = "nix-shell",
        args = { "--pure", "-p", "delve", "--run", "dlv", "dap", "-l", "127.0.0.1:${port}" },
      },
    })
  end
end

dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}",
  },
  {
    type = "delve",
    name = "Debug test",
    request = "launch",
    mode = "test",
    program = "${file}",
  },
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
}

-- Python (debugpy) with nix-shell
dap.adapters.python = {
  type = "executable",
  command = "nix-shell",
  args = { "--pure", "-p", "python3", "python3Packages.debugpy", "--run", "python", "-m", "debugpy.adapter" },
}
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return "nix-shell --pure -p python3 python3Packages.debugpy --run python"
    end,
  },
}

-- Bash (bashdb) - not available on macOS
if vim.fn.has("mac") == 0 then
  dap.adapters.bashdb = {
    type = "executable",
    command = "nix-shell",
    args = { "-p", "bashdb", "--run", "bashdb" },
  }

  dap.configurations.sh = {
    {
      type = "bashdb",
      request = "launch",
      name = "Launch file",
      showDebugOutput = true,
      pathBashdb = function()
        return vim.fn.system('nix-shell --pure -p bashdb --run "which bashdb"'):gsub("\n", "")
      end,
      pathBashdbLib = function()
        return vim.fn.system('nix-shell --pure -p bashdb --run "dirname $(which bashdb)"'):gsub("\n", "") .. "/../share/bashdb"
      end,
      trace = true,
      file = "${file}",
      program = "${file}",
      cwd = "${workspaceFolder}",
      pathCat = "cat",
      pathBash = function()
        return vim.fn.system('nix-shell --pure -p bash --run "which bash"'):gsub("\n", "")
      end,
      pathMkfifo = "mkfifo",
      pathPkill = "pkill",
      args = {},
      env = {},
      terminalKind = "integrated",
    },
  }
end
