return {
    'stevearc/conform.nvim',
    opts = {
        formatters = {
            --           ruff_fix = { append_args = { "--unsafe-fixes" } },
        },
        formatters_by_ft = {
            javascript = { "biome", "biome-organize-imports", "eslint_d" },
            typescript = { "biome", "biome-organize-imports", "eslint_d" },
            python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
            lua = { lsp_format = "fallback" },
            java = { "spotless_maven" },
            sql = { "sqlfluff" },
        },
        format_on_save = function(bufnr)
            if not require("formatter").enabled_on_buffer(bufnr) then
                return
            end
            return { timeout_ms = 500, lsp_format = "fallback" }
        end,
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
