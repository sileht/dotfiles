return {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    lazy = false,
    branch = 'main',
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({})
        local plugins = require('nvim-treesitter').get_available()
        local ignore_install = {} -- "phpdoc", "wgsl", "jsonc", "blueprint", "fusion" }
        local to_install = vim.tbl_filter(function(item)
            return not vim.tbl_contains(ignore_install, item)
        end, plugins)
        require("nvim-treesitter").install(to_install)
        vim.api.nvim_create_autocmd('BufEnter', {
            callback = function()
                local ok, _ = pcall(vim.treesitter, 'start')
                if ok then
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end
}
