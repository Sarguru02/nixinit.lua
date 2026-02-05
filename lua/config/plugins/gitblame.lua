return {
	"f-person/git-blame.nvim",
	event = "VeryLazy",
	opts = {
		enabled = true,
		message_template = " <author> • <summary> • <date> • <<sha>>", -- template for the blame message, check the Message template section for more options
		date_format = "%d-%m-%Y", -- template for the date, check Date format section for more options
		virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
	},
}
