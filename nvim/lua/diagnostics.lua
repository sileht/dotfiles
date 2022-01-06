local M = {}

M.signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

function M.setup()
    vim.diagnostic.config({
        -- virtual_text = { spacing = 4, prefix = "●" },
        virtual_text = false,
        sign = true,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
    })
    vim.api.nvim_command("autocmd CursorHold <buffer> lua vim.diagnostic.open_float({focusable=false})")

    local default_hanlder = vim.lsp.handlers["textDocument/publishDiagnostics"]
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(...)
        default_hanlder(...)
        vim.diagnostic.setqflist()
        vim.api.nvim_command("wincmd p")
    end

    vim.diagnostic.setqflist()

    for type, icon in pairs(M.signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
end

return M
