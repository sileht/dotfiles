return {
    "uloco/bluloco.nvim",
    dependencies = { 'rktjmp/lush.nvim' },
    lazy         = false,
    priority     = 1000,
    config       = function()
        require("bluloco").setup({
            style       = "dark", -- "auto" | "dark" | "light"
            transparent = false,
            italics     = false,
        })
        vim.cmd('colorscheme bluloco')
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
