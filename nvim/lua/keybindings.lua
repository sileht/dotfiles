require("which-key").setup()

function open_in_browser()
    local cb = require('gitlinker.actions').open_in_browser
    require('gitlinker').get_buf_range_url('n', { action_callback = cb })
end

require("which-key").add(
    {
        { "<F10>",     require('formatter').toggle,                                            desc = "Toggle FormatWrite" },
        { "<F11>",     ":set spell!<cr>",                                                      desc = "Toggle spell" },
        { "<F12>",     require('utils').toggle_focus,                                          desc = "Show/Hide keybindings" },
        { "<C-k>",     vim.lsp.buf.signature_help,                                             desc = "Show signature" },
        { "<F5>",      vim.lsp.buf.rename,                                                     desc = "Rename" },
        { "<F6>",      ":IncRename ",                                                          desc = "Rename (Fancy)" },
        { "K",         vim.lsp.buf.hover,                                                      desc = "Documentation" },
        { "gP",        vim.diagnostic.goto_prev,                                               desc = "Diagnostic previous" },
        { "gN",        vim.diagnostic.goto_next,                                               desc = "Diagnostic next" },
        { "gD",        vim.lsp.buf.declaration,                                                desc = "Go declaration" },
        { "gi",        vim.lsp.buf.implementation,                                             desc = "Go implementation" },
        { "gd",        require('telescope.builtin').lsp_definitions,                           desc = "Go definitions" },
        { "gr",        require('telescope.builtin').lsp_references,                            desc = "Go references" },
        { "<leader>b", ":Git blame",                                                           desc = "Git Blame" },
        { "<leader>D", require('gitsigns').toggle_deleted,                                     desc = "Git show deleted" },
        { "<leader>o", open_in_browser,                                                        desc = "Open in GitHub" },
        { "<leader>d", function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, desc = "Diagnostics" },
        { "<leader>c", require('telescope.builtin').git_commits,                               desc = "Git commit" },
        --{ "<leader>f", require('telescope.builtin').find_files, desc = "find" },
        { "<leader>f", require('telescope.builtin').git_files,                                 desc = "Git files" },
        { "<leader>g", require('telescope.builtin').live_grep,                                 desc = "Grep" },
        { "<leader>k", require('telescope.builtin').keymaps,                                   desc = "Keymaps" },
        --{ "<leader>fb", require('telescope.builtin').buffers, desc = "buffer" },
        { "<leader>h", require('telescope.builtin').help_tags,                                 desc = "help tags" },
        --{ "<leader>n", require('dropbar.api').pick, desc = "dropbar" },
        {
            "<leader>e",
            require("telescope").extensions.file_browser.file_browser,
            desc =
            "File browser"
        },
        { "<leader>a", require("actions-preview").code_actions, desc = "Code action" },
        { "<leader>A", vim.lsp.buf.code_action,                 desc = "Code action" },
        { "<S-left>",  ":BufferPrevious<CR>",                   desc = "Buffer previous" },
        { "<S-right>", ":BufferNext<CR>",                       desc = "Buffer next" },
    }
)
vim.cmd([[
    nnoremap P "0p                            " Paste last yank
    nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
    "cnoreabbrev bd silent! bd
    cnoreabbrev bd :BufferClose<Enter>
    cnoreabbrev bw silent! bw
    "nmap <silent> <S-left>  :bp<Enter>
    "nmap <silent> <S-right> :bn<Enter>
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)
]])
