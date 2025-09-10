local pack_ui = require("ui.pack_ui")

vim.api.nvim_create_user_command("Pack", function()
	pack_ui.show()
end, {
	desc = "Open plugin manager UI",
})