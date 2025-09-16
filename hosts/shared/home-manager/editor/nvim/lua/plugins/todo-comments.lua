return {
	src = "https://github.com/folke/todo-comments.nvim",
	config = function()
		require("todo-comments").setup({
			-- Default configuration
		})

		-- Create mini.pick integration for todos
		local function todo_picker(local_only)
			local search = require("todo-comments.search")
			local current_file = local_only and vim.api.nvim_buf_get_name(0) or nil

			search.search(function(results)
				local filtered_results = {}
				for _, todo in ipairs(results) do
					if not local_only or todo.filename == current_file then
						table.insert(filtered_results, todo)
					end
				end

				local items = {}
				for _, todo in ipairs(filtered_results) do
					local display_text = local_only and string.format("%d: %s", todo.lnum, todo.text)
						or string.format("%s:%d: %s", vim.fn.fnamemodify(todo.filename, ":."), todo.lnum, todo.text)
					table.insert(items, display_text)
				end

				require("mini.pick").start({
					source = {
						items = items,
						name = local_only and "TODOs (Current File)" or "TODOs",
						choose = function(item_idx)
							local todo = filtered_results[item_idx]
							if todo then
								local target_win = require("mini.pick").get_picker_state().windows.target
								vim.api.nvim_win_call(target_win, function()
									vim.cmd("edit " .. vim.fn.fnameescape(todo.filename))
									vim.api.nvim_win_set_cursor(0, { todo.lnum, todo.col - 1 })
								end)
							end
						end,
					},
				})
			end)
		end

		-- Create quickfix function for current buffer only
		local function todo_quickfix_current()
			local search = require("todo-comments.search")
			local current_file = vim.api.nvim_buf_get_name(0)

			search.search(function(results)
				local qf_items = {}
				for _, todo in ipairs(results) do
					if todo.filename == current_file then
						table.insert(qf_items, {
							filename = todo.filename,
							lnum = todo.lnum,
							col = todo.col or 1,
							text = todo.text,
						})
					end
				end
				vim.fn.setqflist(qf_items, "r")
				vim.cmd("copen")
			end)
		end

		-- Keymaps
		vim.keymap.set("n", "<leader>dx", function()
			todo_picker(false)
		end, { desc = "Search TODOs" })
		vim.keymap.set("n", "<leader>dX", function()
			todo_picker(true)
		end, { desc = "Search TODOs (Current File)" })
		vim.keymap.set("n", "<leader>dl", "<cmd>TodoQuickFix<cr>", { desc = "TODO List" })
		vim.keymap.set("n", "<leader>dL", todo_quickfix_current, { desc = "TODO List (Current File)" })
	end,
}
