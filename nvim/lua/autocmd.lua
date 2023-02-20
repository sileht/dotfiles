

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
        if buftype == "quickfix" then
            return
        else
            local current_file_dir = vim.fn.expand("%:p:h")
            if vim.fn.isdirectory(current_file_dir) ~= 0 then
                vim.cmd("lcd " .. current_file_dir)
            end
        end
    end
})
require("utils").toggle_formatter({silent=true})
