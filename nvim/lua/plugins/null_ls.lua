return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.diagnostics.mypy.with({
                    only_local = ".venv/bin",
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    debounce = 250,
                    timeout = 20000,
                    runtime_condition = function(params)
                        return vim.fn.filereadable(params.bufname) == 1
                    end
                }),
                null_ls.builtins.diagnostics.yamllint.with({
                    only_local = ".venv/bin",
                }),
                null_ls.builtins.diagnostics.actionlint.with({
                    runtime_condition = function(params)
                        return params.lsp_params.textDocument.uri:match(".github/workflow") ~= nil
                    end,
                }),
            },
            debug = true
        })
    end,
}
