---@type vim.lsp.Config

-- Helper function to check if a command exists
local function command_exists(cmd)
	return vim.fn.executable(cmd) == 1
end

-- Helper function to find flake configurations dynamically
local function get_flake_configurations()
	local flake_path = vim.fs.find("flake.nix", {
		upward = true,
		path = vim.fn.getcwd(),
	})[1]

	if not flake_path then
		return nil
	end

	local flake_dir = vim.fs.dirname(flake_path)

	-- Try to read and parse flake.nix to find configurations
	local flake_content = {}
	local file = io.open(flake_path, "r")
	if file then
		local content = file:read("*all")
		file:close()

		-- Extract configuration names (basic pattern matching)
		-- This is a simple approach - could be made more sophisticated
		for config_type in pairs({ nixosConfigurations = true, darwinConfigurations = true }) do
			for name in content:gmatch(config_type .. "%s*=%s*{[^}]*(%w+)[^}]*}") do
				if not flake_content[config_type] then
					flake_content[config_type] = {}
				end
				table.insert(flake_content[config_type], name)
			end
		end
	end

	return flake_dir, flake_content
end

-- Helper function to detect the current system
local function get_system_type()
	local uname = vim.fn.system("uname -s"):gsub("%s+", "")
	if uname == "Darwin" then
		return "darwin"
	elseif uname == "Linux" then
		return "nixos"
	end
	return "linux" -- fallback
end

-- Dynamic configuration builder
local function build_nixd_settings()
	local settings = {
		nixd = {
			nixpkgs = {
				expr = "import <nixpkgs> { }",
			},
			formatting = {},
			options = {},
		},
	}

	-- Dynamic formatter detection
	settings.nixd.formatting.command = { "alejandra" }

	-- Try to find flake and configure options dynamically
	local flake_dir, flake_configs = get_flake_configurations()
	local system_type = get_system_type()

	if flake_dir and flake_configs then
		local flake_expr = string.format("builtins.getFlake (toString %s)", flake_dir)

		-- Configure nixos options if available
		if flake_configs.nixosConfigurations then
			local nixos_config = flake_configs.nixosConfigurations[1] -- Use first found
			if nixos_config then
				settings.nixd.options.nixos = {
					expr = string.format(
						"let flake = %s; in flake.nixosConfigurations.%s.options",
						flake_expr,
						nixos_config
					),
				}

				-- Try to configure home-manager options
				settings.nixd.options["home-manager"] = {
					expr = string.format(
						"let flake = %s; in flake.nixosConfigurations.%s.config.home-manager.users.${USER}.options or {}",
						flake_expr,
						nixos_config
					),
				}
			end
		end

		-- Configure darwin options if available
		if flake_configs.darwinConfigurations then
			local darwin_config = flake_configs.darwinConfigurations[1] -- Use first found
			if darwin_config then
				settings.nixd.options.darwin = {
					expr = string.format(
						"let flake = %s; in flake.darwinConfigurations.%s.options",
						flake_expr,
						darwin_config
					),
				}
			end
		end

		-- If we're on the appropriate system, try to use system-specific configs
		if system_type == "darwin" and flake_configs.darwinConfigurations then
			-- Try to detect hostname for more precise config
			local hostname = vim.fn.system("hostname -s"):gsub("%s+", "")
			for _, config in ipairs(flake_configs.darwinConfigurations) do
				if config:find(hostname) then
					settings.nixd.options.darwin.expr =
						string.format("let flake = %s; in flake.darwinConfigurations.%s.options", flake_expr, config)
					break
				end
			end
		end
	else
		-- Fallback configurations for non-flake setups
		if system_type == "nixos" then
			settings.nixd.options.nixos = {
				expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.$(hostname).options or {}',
			}
		end
	end

	return settings
end

-- Dynamic command setup
local function get_nixd_cmd()
	-- Try different ways to get nixd
	if command_exists("nixd") then
		return { "nixd" }
	elseif command_exists("nix") then
		-- Use nix shell if nixd isn't directly available
		return { "nix", "shell", "nixpkgs#nixd", "-c", "nixd" }
	elseif command_exists("nix-shell") then
		-- Fallback to nix-shell
		return { "nix-shell", "-p", "nixd", "--run", "nixd" }
	else
		-- Last resort - assume nixd is in PATH
		return { "nixd" }
	end
end

-- Enhanced root detection
local function find_root_markers()
	local markers = {
		"flake.nix",
		"flake.lock",
		"shell.nix",
		"default.nix",
		".envrc", -- direnv
		"result", -- nix-build result
		".git",
		"src",
	}

	-- Add more specific markers based on common patterns
	local cwd = vim.fn.getcwd()
	if vim.fn.isdirectory(cwd .. "/nixos") == 1 then
		table.insert(markers, "nixos")
	end
	if vim.fn.isdirectory(cwd .. "/modules") == 1 then
		table.insert(markers, "modules")
	end

	return markers
end

return {
	cmd = get_nixd_cmd(),
	filetypes = { "nix" },
	root_markers = find_root_markers(),
	settings = build_nixd_settings(),

	-- Additional capabilities
	capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	}),

	-- Custom initialization
	on_init = function(client, _)
		-- Notify about the configuration being used
		local config_info = "nixd initialized"
		if client.config.settings.nixd.options.nixos then
			config_info = config_info .. " with NixOS options"
		end
		if client.config.settings.nixd.options.darwin then
			config_info = config_info .. " with Darwin options"
		end
		if client.config.settings.nixd.options["home-manager"] then
			config_info = config_info .. " with Home Manager options"
		end

		-- vim.notify(config_info, vim.log.levels.INFO)
	end,

	-- Handle workspace folders for better project detection
	on_new_config = function(config, root_dir)
		-- Update settings based on the specific root directory
		if root_dir then
			-- You could add root-specific logic here
			config.cmd_cwd = root_dir
		end
	end,
}
