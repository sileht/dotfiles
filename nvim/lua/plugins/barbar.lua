return {
    'romgrk/barbar.nvim',
    dependencies = {
        'lewis6991/gitsigns.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
        maximum_padding = 1,
        insert_at_end = true,
        icons = {
            button = '',
            diagnostics = {
                [vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
                [vim.diagnostic.severity.WARN] = { enabled = true, icon = " " },
                [vim.diagnostic.severity.INFO] = { enabled = true, icon = " " },
                [vim.diagnostic.severity.HINT] = { enabled = true, icon = " " },
            },
        }
    },
}
