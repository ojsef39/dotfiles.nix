return {
	src = "https://github.com/folke/todo-comments.nvim",
	config = function()
		require("todo-comments").setup({
			-- Default configuration
		})

		-- Create mini.pick integration for todos using correct API
		local function todo_picker()
			local search = require("todo-comments.search")

			search.search(function(results)
				local items = {}
				local lookup = {}

				for i, todo in ipairs(results) do
					local relative_path = vim.fn.fnamemodify(todo.filename, ":.")
					local display_text = string.format("%s:%d: %s", relative_path, todo.lnum, todo.text)
					items[i] = display_text
					lookup[display_text] = {
						filename = todo.filename,
						lnum = todo.lnum,
						col = todo.col or 1,
					}
				end

				require("mini.pick").start({
					source = {
						items = items,
						name = "TODOs",
						choose = function(item)
							if item and lookup[item] then
								local todo = lookup[item]
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

		-- Keymaps
		vim.keymap.set("n", "<leader>dx", todo_picker, { desc = "Search TODOs" })
		vim.keymap.set("n", "<leader>dl", "<cmd>TodoQuickFix<cr>", { desc = "TODO List" })
	end,
}
