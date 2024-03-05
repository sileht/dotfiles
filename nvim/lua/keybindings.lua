require("which-key").setup()
require("which-key").register(
    {
        ["<F10>"] = { function() require('formatter').toggle() end, "Toggle FormatWrite" },
        ["<F11>"] = { ":set spell!<cr>", "Toggle spell" },
        ["<F12>"] = { function() require('utils').toggle_focus() end, "Show/Hide keybindings" },
        ["<C-k>"] = { function() vim.lsp.buf.signature_help() end, "Show signature" },
        ["<F5>"] = { function() vim.lsp.buf.rename() end, "Rename" },
        ["<F6>"] = { ":IncRename ", "Rename (Fancy)" },
        ["K"] = { function() vim.lsp.buf.hover() end, "Documentation" },
        ["gP"] = { function() vim.diagnostic.goto_prev() end, "Diagnostic previous" },
        ["gN"] = { function() vim.diagnostic.goto_next() end, "Diagnostic next" },
        ["gD"] = { function() vim.lsp.buf.declaration() end, "Go declaration" },
        ["gi"] = { function() vim.lsp.buf.implementation() end, "Go implementation" },
        ["gd"] = { function() require('telescope.builtin').lsp_definitions() end, "Go definitions" },
        ["gr"] = { function() require('telescope.builtin').lsp_references() end, "Go references" },
        ["<leader>b"] = { function() vim.cmd("Git blame") end, "Git Blame" },
        ["<leader>D"] = { function() require('gitsigns').toggle_deleted() end, "Git show deleted" },
        ["<leader>o"] = {
            function()
                local cb = require('gitlinker.actions').open_in_browser
                require('gitlinker').get_buf_range_url('n', { action_callback = cb })
            end,
            "Open in GitHub"
        },
        ["<leader>d"] = { function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, "Diagnostics" },
        ["<leader>c"] = { function() require('telescope.builtin').git_commits() end, "Git commit" },
        --["<leader>f"] = { function() require('telescope.builtin').find_files() end, "find" },
        ["<leader>g"] = { function() require('telescope.builtin').live_grep() end, "Grep" },
        ["<leader>k"] = { function() require('telescope.builtin').keymaps() end, "Keymaps" },
        --["<leader>fb"] = { function() require('telescope.builtin').buffers() end, "buffer" },
        ["<leader>h"] = { function() require('telescope.builtin').help_tags() end, "help tags" },
        ["<leader>e"] = {
            function() require("telescope").extensions.file_browser.file_browser() end,
            "File browser" },
        ["<leader>a"] = { function() vim.lsp.buf.code_action() end, "Code action" },
    }
)
vim.cmd([[
    nnoremap P "0p                            " Paste last yank
    nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
    cnoreabbrev bd silent! bd
    cnoreabbrev bw silent! bw
    nmap <silent> <S-left>  :bp<Enter>
    nmap <silent> <S-right> :bn<Enter>
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)
]])
