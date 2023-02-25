-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})
-- Highlight on yank
vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'YankHighlight',
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '100' })
    end
})

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        local buftype = vim.fn.getbufvar(vim.fn.bufnr(), "&buftype")
        if buftype == "quickfix" or buftype == "nofile" then
            return
        else
            local current_file_dir = vim.fn.expand("%:p:h")
            if vim.fn.isdirectory(current_file_dir) ~= 0 then
                vim.cmd("lcd " .. current_file_dir)
            end
        end
    end
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = require("formatter").may_format
})

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" },
    { pattern = "*.py", callback = require("linters").run_linter }
)

vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(params)
        for namespace_id, namespace in pairs(vim.diagnostic.get_namespaces()) do
            if string.find(namespace.name, "NULL_LS_SOURCE_") == 1 then
                vim.diagnostic.reset(namespace_id, params.buf)
            end
        end
    end
})
