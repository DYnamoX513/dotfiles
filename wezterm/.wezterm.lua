-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Spawn a fish shell in login mode
config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
-- config.color_scheme = "Railscasts (base16)"
config.color_scheme = "iceberg-dark"
-- config.color_scheme = 'Mariana'
-- config.color_scheme = "N0tch2k"
config.font = wezterm.font_with_fallback({
	-- mono-space
	{ family = "Iosevka Term SS08 Extended", scale = 1.00 },
	-- "IBM Plex Mono",
	-- "Input Mono Narrow",

	-- "Symbols Nerd Font",
	-- 你好
	"PingFang SC",
})

local uni_font_size = 13.0
config.font_size = uni_font_size

-- config.line_height = 1.0
config.cell_width = 0.9 -- more compact horizontally

config.window_frame = {
	font = wezterm.font({ family = "SF Pro Text" }),
	font_size = uni_font_size,
}

config.tab_bar_at_bottom = true
config.window_padding = {
	left = 2,
	right = 2,
	top = 2,
	bottom = 2,
}

config.initial_cols = 120
config.initial_rows = 30

-- CTRL + SHIFT + <SPACE> conflict with MacOS's 'Select the previous input source'
config.keys = {
	{ key = "s", mods = "SHIFT|CTRL", action = wezterm.action.QuickSelect },
}

config.enable_scroll_bar = true
config.min_scroll_bar_height = "2cell"
config.scrollback_lines = 30000 -- default 3500
config.colors = {
	scrollbar_thumb = "#a0a0a0",
}

config.use_fancy_tab_bar = false
config.tab_max_width = 32
-- Darwin ~/Library/Application Support/wezterm/plugins
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
-- Need manually update (git pull)
tabline.setup({
	options = {
		theme = config.color_scheme,
		-- section_separators = "",
		-- component_separators = "",
		-- tab_separators = {
		-- 	left = "",
		-- 	right = "",
		-- },
		section_separators = {
			left = wezterm.nerdfonts.ple_right_half_circle_thick,
			right = wezterm.nerdfonts.ple_left_half_circle_thick,
		},
		component_separators = {
			-- left = wezterm.nerdfonts.ple_right_half_circle_thin,
			-- right = wezterm.nerdfonts.ple_left_half_circle_thin,
			left = "|",
			right = "|",
		},
		tab_separators = {
			left = wezterm.nerdfonts.ple_right_half_circle_thick,
			right = wezterm.nerdfonts.ple_left_half_circle_thick,
		},
	},
	sections = {
		-- tab_active = {
		-- 	"index",
		-- 	{ "cwd", max_length = 10, padding = { left = 0, right = 1 } },
		-- 	{ "zoomed", padding = 0 },
		-- },
		tabline_y = {
			"datetime",
			--[[ "battery" ]]
		},
		tabline_z = {
			--[[ "hostname" ]]
		},
	},
})

-- Below configures T-SSH domains
local function parse_ssh_config()
	local host_list = {}
	local config_path = os.getenv("HOME") .. "/.ssh/config"

	local file = io.open(config_path, "r")
	if not file then
		return host_list -- No config file, empty
	end

	for line in file:lines() do
		if line:sub(1, 5) == "Host " then
			local hosts = {}
			for host in line:gmatch("%S+") do
				table.insert(hosts, host)
			end
			-- Remove the first 'Host'
			table.remove(hosts, 1)
			for _, host in ipairs(hosts) do
				table.insert(host_list, host)
			end
		end
	end

	file:close()
	return host_list
end

-- local function make_tssh_label_func(name)
-- 	return wezterm.format({
-- 		{ Foreground = { AnsiColor = "Blue" } },
-- 		{ Text = "TSSH " .. name },
-- 	})
-- end

local function make_tssh_fixup_func(host)
	return function(cmd)
		cmd.args = {
			os.getenv("SHELL"),
			"-lc",
			"tssh " .. host,
		}
		cmd.set_environment_variables = {
			SSH_AUTH_SOCK = os.getenv("SSH_AUTH_SOCK"),
		}
		return cmd
	end
end

local function compute_exec_domains()
	-- test tssh installation
	local success, stdout, stderr = wezterm.run_child_process({
		os.getenv("SHELL"),
		"-lc",
		"tssh -V",
	})
	local color
	local text
	if success then
		color = "Blue"
		text = stdout:gsub("^%s*(.-)%s*$", "%1")
	else
		color = "Red"
		text = "tssh -V failed: " .. stderr
	end

	local label = wezterm.format({
		{ Foreground = { AnsiColor = color } },
		{ Text = text },
	})

	local exec_domains = {}
	for _, host in ipairs(parse_ssh_config()) do
		table.insert(exec_domains, wezterm.exec_domain("T.SSH " .. host, make_tssh_fixup_func(host), label))
	end
	return exec_domains
end

config.exec_domains = compute_exec_domains()

-- and finally, return the configuration to wezterm
return config
