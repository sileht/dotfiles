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
        local name = vim.api.nvim_buf_get_name(0)
        local buftype = vim.fn.getbufvar(vim.fn.bufnr(), "&buftype")
        if buftype == "" and name ~= "" then
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

function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function() set_terminal_keymaps() end
})

vim.api.nvim_create_user_command("T", "ToggleTerm", {})

vim.api.nvim_create_augroup("qf", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
    group = "qf",
    pattern = "qf",
    command = "set nobuflisted"
})
