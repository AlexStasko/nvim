local colorizer = require 'colorizer'
local comment = require 'Comment'
local gitsigns = require 'gitsigns'
local noice = require 'noice'
local notify = require 'notify'
local catppuccin = require 'catppuccin'

local function init()
	colorizer.setup {}

	comment.setup {}

	gitsigns.setup {}

	notify.setup {
		render = "wrapped-compact",
		timeout = 2500,
		background_colour = "#000000",
	}

	noice.setup {
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			inc_rename = false,
			long_message_to_split = true,
			lsp_doc_border = false,
		},
	}

	catppuccin.setup {
		flavour = "macchiato",
		integrations = {
			cmp = true,
			gitsigns = true,
			native_lsp = {
				enabled = true,
			},
			telescope = true,
			treesitter = true,
		},
		term_colors = true,
		transparent_background = true,
	}

	vim.cmd.colorscheme "catppuccin"
end

return {
	init = init,
}
