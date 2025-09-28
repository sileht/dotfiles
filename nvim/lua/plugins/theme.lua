return {
    "EdenEast/nightfox.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
        require("nightfox").setup({ options = { dim_inactive = true } })
        --vim.cmd.colorscheme("carbonfox")
        vim.cmd.colorscheme("duskfox")
    end
}

--[[ return {
    "rebelot/kanagawa.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
        require("kanagawa").setup({
            compile = true,
        })
        vim.cmd("colorscheme kanagawa")
    end
} ]]

--[[ return {
    "bluz71/vim-moonfly-colors",
    name     = "moonfly",
    lazy     = false,
    priority = 1000,
    config   = function()
        vim.g.moonflyCursorColor = true
        vim.g.moonflyNormalFloat = true
        --vim.g.moonflyTransparent = true
        vim.g.moonflyVirtualTextColor = true
        vim.g.moonflyUnderlineMatchParen = true
        vim.g.moonflyWinSeparator = 2
        vim.cmd("colorscheme moonfly")
    end
} ]]
