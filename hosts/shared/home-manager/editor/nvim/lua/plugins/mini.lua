return {
	src = "https://github.com/echasnovski/mini.nvim",
	defer = true,
	dependencies = {
		{
			src = "https://github.com/dmtrKovalenko/fff.nvim",
			name = "fff.nvim",
			data = { build = "nix run .#release" },
		},
	},
	config = function()
		require("mini.surround").setup()
		require("mini.bufremove").setup()
		require("mini.ai").setup()
		require("mini.cursorword").setup()
		require("mini.icons").setup()
		require("mini.extra").setup()

		-- move
		require("mini.move").setup({
			-- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
			mappings = {
				left = "<S-h>",
				right = "<S-l>",
				down = "<S-j>",
				up = "<S-k>",
			},
		})

		-- picker
		local picker_width = math.min(120, math.floor(vim.o.columns * 0.8))
		local picker_height = math.min(30, math.floor(vim.o.lines * 0.6))
		require("mini.pick").setup({
			mappings = {
				choose_marked = "<C-q>",
			},
			window = {
				config = function()
					return {
						anchor = "SW",
						col = math.floor((vim.o.columns - picker_width) / 2),
						row = vim.o.lines - 3,
						width = picker_width,
						height = picker_height,
						relative = "editor",
					}
				end,
				prompt_prefix = " ",
			},
			options = {
				use_cache = true,
			},
		})
		vim.ui.select = MiniPick.ui_select
		---@class FFFItem
		---@field name string
		---@field path string
		---@field relative_path string
		---@field size number
		---@field modified number
		---@field total_frecency_score number
		---@field modification_frecency_score number
		---@field access_frecency_score number
		---@field git_status string

		---@class PickerItem
		---@field text string
		---@field path string
		---@field score number

		---@class FFFPickerState
		---@field current_file_cache string
		local state = {}

		local ns_id = vim.api.nvim_create_namespace("MiniPick FFFiles Picker")

		---@param query string|nil
		---@return PickerItem[]
		local function find(query)
			local file_picker = require("fff.file_picker")

			query = query or ""
			---@type FFFItem[]
			local fff_result = file_picker.search_files(query, 100, 4, state.current_file_cache, false)

			local items = {}
			for _, fff_item in ipairs(fff_result) do
				local item = {
					text = fff_item.relative_path,
					path = fff_item.path,
					score = fff_item.total_frecency_score,
				}
				table.insert(items, item)
			end

			return items
		end

		---@param items PickerItem[]
		local function show(buf_id, items)
			local icon_data = {}

			-- Show items
			local items_to_show = {}
			for i, item in ipairs(items) do
				local icon, hl, _ = MiniIcons.get("file", item.text)
				icon_data[i] = { icon = icon, hl = hl }

				items_to_show[i] = string.format("%s %s", icon, item.text)
			end
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, items_to_show)

			vim.api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)

			local icon_extmark_opts = { hl_mode = "combine", priority = 200 }
			for i, item in ipairs(items) do
				-- Highlight Icons
				icon_extmark_opts.hl_group = icon_data[i].hl
				icon_extmark_opts.end_row, icon_extmark_opts.end_col = i - 1, 1
				vim.api.nvim_buf_set_extmark(buf_id, ns_id, i - 1, 0, icon_extmark_opts)

				-- Highlight score
				local col = #items_to_show[i] - #tostring(item.score) - 3
				icon_extmark_opts.hl_group = "FFFileScore"
				icon_extmark_opts.end_row, icon_extmark_opts.end_col = i - 1, #items_to_show[i]
				vim.api.nvim_buf_set_extmark(buf_id, ns_id, i - 1, col, icon_extmark_opts)
			end
		end

		local function run()
			-- Setup fff.nvim
			local file_picker = require("fff.file_picker")
			if not file_picker.is_initialized() then
				local setup_success = file_picker.setup()
				if not setup_success then
					vim.notify("Could not setup fff.nvim", vim.log.levels.ERROR)
					return
				end
			end

			-- Cache current file to deprioritize in fff.nvim
			if not state.current_file_cache then
				local current_buf = vim.api.nvim_get_current_buf()
				if current_buf and vim.api.nvim_buf_is_valid(current_buf) then
					local current_file = vim.api.nvim_buf_get_name(current_buf)
					if current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
						local relative_path = vim.fs.relpath(vim.uv.cwd(), current_file)
						state.current_file_cache = relative_path
					else
						state.current_file_cache = nil
					end
				end
			end

			-- Start picker
			MiniPick.start({
				source = {
					name = "FFFiles",
					items = find,
					match = function(_, _, query)
						local items = find(table.concat(query))
						MiniPick.set_picker_items(items, { do_match = false })
					end,
					show = show,
				},
			})

			state.current_file_cache = nil -- Reset cache
		end

		MiniPick.registry.fffiles = run

		-- hipatterns
		local hipatterns = require("mini.hipatterns")
		hipatterns.setup({
			highlighters = {
				-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		})

		-- clue
		local miniclue = require("mini.clue")
		miniclue.setup({
			triggers = {
				-- Leader triggers
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },

				-- Built-in completion
				{ mode = "i", keys = "<C-x>" },

				-- `g` key
				{ mode = "n", keys = "g" },
				{ mode = "x", keys = "g" },

				-- Marks
				{ mode = "n", keys = "'" },
				{ mode = "n", keys = "`" },
				{ mode = "x", keys = "'" },
				{ mode = "x", keys = "`" },

				-- Registers
				{ mode = "n", keys = '"' },
				{ mode = "x", keys = '"' },
				{ mode = "i", keys = "<C-r>" },
				{ mode = "c", keys = "<C-r>" },

				-- Window commands
				{ mode = "n", keys = "<C-w>" },

				-- `z` key
				{ mode = "n", keys = "z" },
				{ mode = "x", keys = "z" },
			},

			clues = {
				-- Custom leader key descriptions
				{ mode = "n", keys = "<Leader>b", desc = "Buffer" },
				{ mode = "n", keys = "<Leader>c", desc = "Command" },
				{ mode = "n", keys = "<Leader>d", desc = "Debug" },
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

				-- Add specific mappings for clarity
				{ mode = "n", keys = "<Leader>D", desc = "Diagnostic Loclist" },

				-- Built-in clues
				miniclue.gen_clues.builtin_completion(),
				miniclue.gen_clues.g(),
				miniclue.gen_clues.marks(),
				miniclue.gen_clues.registers(),
				miniclue.gen_clues.windows(),
				miniclue.gen_clues.z(),
			},

			window = {
				delay = 200, -- delay in milliseconds
			},
		})

		-- notifier
		-- require('mini.notify').setup({
		--     content = {
		--         -- Show more recent notifications first
		--         sort = function(notif_arr)
		--             table.sort(
		--                 notif_arr,
		--                 function(a, b) return a.ts_update > b.ts_update end
		--             )
		--             return notif_arr
		--         end,
		--     },
		--     lsp_progress = {
		--         enable = false,
		--     },
		--     window = {
		--         winblend = 0
		--     }
		-- })
		-- vim.notify = require('mini.notify').make_notify()

		-- starter
		local starter = require("mini.starter")
		starter.setup({
			items = {
				starter.sections.builtin_actions(),
			},
			content_hooks = {
				starter.gen_hook.aligning("center", "center"),
			},
			footer = "",
			silent = true,
		})

		-- statusline
		-- Helper function to get LSP clients
		local function get_lsp_clients()
			local clients = {}
			local buf_clients = vim.lsp.get_clients({ bufnr = 0 })

			for _, client in ipairs(buf_clients) do
				if client.name ~= "null-ls" and client.name ~= "copilot" then
					table.insert(clients, client.name)
				end
			end

			if #clients == 0 then
				return ""
			end

			return "[" .. table.concat(clients, ",") .. "]"
		end

		-- Custom location function showing only line and percentage
		local function simple_location()
			local line = vim.fn.line(".")
			local total_lines = vim.fn.line("$")
			local percentage = math.floor((line / total_lines) * 100)
			return string.format(" %d:%d%%", line, percentage)
		end

		local function get_filetype_with_icon()
			local filetype = vim.bo.filetype
			if filetype == "" then
				return ""
			end

			-- Get icon from mini.icons
			local icon = ""
			local has_mini_icons, mini_icons = pcall(require, "mini.icons")
			if has_mini_icons then
				local file_icon = mini_icons.get("filetype", filetype)
				if file_icon then
					icon = file_icon .. " "
				end
			end

			return "" .. icon .. filetype
		end

		-- Custom diagnostics function using mini.icons
		local function get_diagnostics_with_icons()
			local counts = vim.diagnostic.count(0)
			if vim.tbl_isempty(counts) then
				return ""
			end

			local parts = {}

			-- Error
			if counts[vim.diagnostic.severity.ERROR] then
				table.insert(parts, tools.ui.diagnostics.ERROR .. " " .. counts[vim.diagnostic.severity.ERROR])
			end

			-- Warning
			if counts[vim.diagnostic.severity.WARN] then
				table.insert(parts, tools.ui.diagnostics.WARN .. " " .. counts[vim.diagnostic.severity.WARN])
			end

			-- Info
			if counts[vim.diagnostic.severity.INFO] then
				table.insert(parts, tools.ui.diagnostics.INFO .. " " .. counts[vim.diagnostic.severity.INFO])
			end

			-- Hint
			if counts[vim.diagnostic.severity.HINT] then
				table.insert(parts, tools.ui.diagnostics.HINT .. " " .. counts[vim.diagnostic.severity.HINT])
			end

			return table.concat(parts, " ")
		end

		-- Custom content function for cleaner statusline
		local function statusline_content()
			local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 999999999 })
			local git = MiniStatusline.section_git({ trunc_width = 75 })
			local diagnostics = get_diagnostics_with_icons()
			local location = simple_location()
			local lsp_status = get_lsp_clients()
			local filetype = get_filetype_with_icon()

			-- Get breadcrumbs from navic if available
			local breadcrumbs = ""
			local has_navic, navic = pcall(require, "nvim-navic")
			if has_navic and navic.is_available() then
				local navic_location = navic.get_location()
				if navic_location ~= "" then
					-- Calculate available space more conservatively
					local win_width = vim.api.nvim_win_get_width(0)
					local max_width = math.floor(win_width * 0.6) -- More conservative

					if #navic_location > max_width then
						-- Split on separators and keep the most specific parts
						local parts = vim.split(navic_location, " › ")
						local result = ""
						local total_len = 3 -- for "..."

						-- Start from the end (most specific) and work backwards
						for i = #parts, 1, -1 do
							local part_len = #parts[i] + (i < #parts and 3 or 0) -- +3 for " › "
							if total_len + part_len <= max_width then
								if result == "" then
									result = parts[i]
								else
									result = parts[i] .. " › " .. result
								end
								total_len = total_len + part_len
							else
								break
							end
						end

						-- Add ellipsis if we truncated
						if total_len < #navic_location then
							result = "..." .. (result ~= "" and " › " .. result or "")
						end

						breadcrumbs = result
					else
						breadcrumbs = navic_location
					end
				end
			end

			return MiniStatusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
				"%<", -- Mark general truncate point
				{ hl = "MiniStatuslineFilename", strings = { breadcrumbs } },
				"%=", -- End left alignment
				{ hl = "MiniStatuslineFileinfo", strings = { lsp_status, filetype } },
				{ hl = mode_hl, strings = { location } },
			})
		end

		-- Custom inactive statusline content
		local function statusline_content_inactive()
			local filename = vim.fn.expand("%:t")
			if filename == "" then
				filename = "[No Name]"
			end

			return MiniStatusline.combine_groups({
				{ hl = "MiniStatuslineInactive", strings = { " " .. filename .. " " } },
			})
		end

		require("mini.statusline").setup({
			content = {
				active = statusline_content,
				inactive = statusline_content_inactive,
			},
			use_icons = vim.g.have_nerd_font or false,
			set_vim_settings = false, -- Keep your existing statusline settings
		})
		-- Keymaps
		vim.keymap.set("n", "<leader>bd", function()
			MiniBufremove.delete()
		end, { desc = "Delete Buffer", silent = true })

		-- { '<leader>n',  function() MiniNotify.show_history() end,                             desc = "Show Notification History", remap = true, silent = true },
		vim.keymap.set("n", "<leader><space>", function()
			MiniPick.registry.fffiles()
		end, { desc = "FFF Files", silent = true })

		vim.keymap.set("n", "<leader>fg", function()
			MiniPick.builtin.grep_live()
		end, { desc = "Live Grep", silent = true })

		vim.keymap.set("n", "<leader>ls", function()
			MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
		end, { desc = "Workspace Symbols", silent = true })

		vim.keymap.set("n", "<leader>dr", function()
			MiniExtra.pickers.diagnostic()
		end, { desc = "Diagnostics", silent = true })

		vim.keymap.set("n", "<leader>gi", function()
			MiniExtra.pickers.git_hunks()
		end, { desc = "Git Hunks", silent = true })

		vim.keymap.set("n", "<leader>bf", function()
			MiniPick.builtin.buffers()
		end, { desc = "Buffers", silent = true })

		vim.keymap.set("n", "<leader>ch", function()
			MiniExtra.pickers.history()
		end, { desc = "Command History", silent = true })

		vim.keymap.set("n", "<leader>mk", function()
			MiniExtra.pickers.keymaps()
		end, { desc = "Keymaps", silent = true })

		vim.keymap.set("n", "<leader>ms", function()
			MiniExtra.pickers.marks()
		end, { desc = "Marks", silent = true })
	end,
}
