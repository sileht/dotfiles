return {
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            javascript = { "biome", "biome-organize-imports", "eslint_d" },
            typescript = { "biome", "biome-organize-imports", "eslint_d" },
            python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
            lua = { "lsp_format" },
            java = { "spotless_maven" },
            sql = { "sqlfluff" },
        },
        format_on_save = function(bufnr)
            -- Disable autoformat on certain filetypes
            local ignore_filetypes = {}
            if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                return
            end
            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end
            -- Disable autoformat for files in a certain path
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname:match("/node_modules/") then
                return
            end
            return { timeout_ms = 500, lsp_format = "fallback" }
        end,
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
