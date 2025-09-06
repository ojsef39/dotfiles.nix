return {
	src = "https://github.com/mfussenegger/nvim-dap",
	defer = true,
	dependencies = {
		{ src = "https://github.com/rcarriga/nvim-dap-ui" },
		{ src = "https://github.com/nvim-neotest/nvim-nio" },
		{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		-- Basic UI setup
		dapui.setup()
		require("nvim-dap-virtual-text").setup({
			virt_text_pos = "eol",
		})

		-- Debug adapters
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
						args = { "-p", "delve", "--run", "dlv dap -l 127.0.0.1:${port}" },
					},
				})
			end
		end

		dap.adapters.python = {
			type = "executable",
			command = "nix-shell",
			args = { "-p", "python3", "python3Packages.debugpy", "--run", "python -m debugpy.adapter" },
		}

		-- bashdb not available on aarch64-darwin (Apple Silicon)
		if vim.fn.has("mac") == 0 then
			dap.adapters.bashdb = {
				type = "executable",
				command = "nix-shell",
				args = { "-p", "bashdb", "--run", "bashdb" },
			}
		end

		-- Configuration for Go using delve
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

		-- Configuration for Python using debugpy
		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				pythonPath = function()
					return "nix-shell -p python3 python3Packages.debugpy --run python"
				end,
			},
		}

		-- Configuration for Bash using bashdb (not available on macOS)
		if vim.fn.has("mac") == 0 then
			dap.configurations.sh = {
				{
					type = "bashdb",
					request = "launch",
					name = "Launch file",
					showDebugOutput = true,
					pathBashdb = function()
						return vim.fn.system('nix-shell -p bashdb --run "which bashdb"'):gsub("\n", "")
					end,
					pathBashdbLib = function()
						return vim.fn.system('nix-shell -p bashdb --run "dirname $(which bashdb)"'):gsub("\n", "")
							.. "/../share/bashdb"
					end,
					trace = true,
					file = "${file}",
					program = "${file}",
					cwd = "${workspaceFolder}",
					pathCat = "cat",
					pathBash = function()
						return vim.fn.system('nix-shell -p bash --run "which bash"'):gsub("\n", "")
					end,
					pathMkfifo = "mkfifo",
					pathPkill = "pkill",
					args = {},
					env = {},
					terminalKind = "integrated",
				},
			}
		end

		-- UI Listeners
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- Keymaps
		vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "Debug Continue", silent = true })
		vim.keymap.set(
			"n",
			"<leader>db",
			"<cmd>lua require'dap'.toggle_breakpoint()<CR>",
			{ desc = "Debug Toggle Breakpoint", silent = true }
		)
		vim.keymap.set("n", "<leader>dn", "<cmd>DapStepOver<CR>", { desc = "Debug Step Over", silent = true })
		vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "Debug Step Into", silent = true })
		vim.keymap.set("n", "<leader>do", "<cmd>DapStepOut<CR>", { desc = "Debug Step Out", silent = true })
		vim.keymap.set("n", "<leader>dd", "<cmd>lua require'dap'.down()<CR>", { desc = "Debug Down", silent = true })
		vim.keymap.set("n", "<leader>ds", "<cmd>DapTerminate<CR>", { desc = "Debug Stop", silent = true })
		vim.keymap.set(
			"n",
			"<leader>dt",
			"<cmd>lua require('dapui').toggle()<CR>",
			{ desc = "Debug Toggle Debug UI", silent = true }
		)
		vim.keymap.set("n", "<leader>da", "<cmd>DapNew<CR>", { desc = "Debug New", silent = true })
		vim.keymap.set(
			"n",
			"<leader>?",
			"<cmd>lua require('dapui').eval(nil, { enter = true })<CR>",
			{ desc = "Debug Eval", silent = true }
		)
	end,
}
