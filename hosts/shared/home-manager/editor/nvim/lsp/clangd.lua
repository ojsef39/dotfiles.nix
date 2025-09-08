---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "--pure", "-p", "llvm", "--run", "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
		"src",
	},
}
