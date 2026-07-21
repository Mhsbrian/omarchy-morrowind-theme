return {
	{ "ellisonleao/gruvbox.nvim" },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				vim.o.background = "light"
				vim.cmd.colorscheme("gruvbox")
			end,
		},
	},
}
