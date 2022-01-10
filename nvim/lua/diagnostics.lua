local M = {}

M.signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
M.open = true

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
    end

    function fgoo()
        vim.diagnostic.setqflist({ open=false })
        local items = vim.fn.getqflist()
        if vim.tbl_isempty(items) then
            vim.cmd("cclose")
        else
            vim.cmd("copen")
            vim.cmd("wincmd p")
        end
        M.open = false
    end


    for type, icon in pairs(M.signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
end

return M
