--return {
--    "uloco/bluloco.nvim",
--    dependencies = { 'rktjmp/lush.nvim' },
--    lazy         = false,
--    priority     = 1000,
--    config       = function()
--        require("bluloco").setup({
--            style       = "dark", -- "auto" | "dark" | "light"
--            transparent = false,
--            italics     = false,
--        })
--        vim.cmd('colorscheme bluloco')
--    end
--}

return {
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
}

--[[
return {
    "bluz71/vim-moonfly-colors",
    enabled = false,
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd('colorscheme moonfly')
    end
}
]] --
