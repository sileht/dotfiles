local M = {}

M.signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

function M.setup()
    -- Automatically update diagnostics
    --[=====[
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = false,
        sign = true,
        update_in_insert = false,
        virtual_text = false, -- { spacing = 4, prefix = "●" },
        severity_sort = true,
    })
    --]=====]
    vim.diagnostic.config({virtual_text = { spacing = 4, prefix = "●" }, sign = true, underline = false})

    for type, icon in pairs(M.signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
end

return M
