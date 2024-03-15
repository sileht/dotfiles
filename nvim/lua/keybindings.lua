require("which-key").setup()
require("which-key").register(
    {
        ["<F10>"] = { require('formatter').toggle, "Toggle FormatWrite" },
        ["<F11>"] = { ":set spell!<cr>", "Toggle spell" },
        ["<F12>"] = { require('utils').toggle_focus, "Show/Hide keybindings" },
        ["<C-k>"] = { vim.lsp.buf.signature_help, "Show signature" },
        ["<F5>"] = { vim.lsp.buf.rename, "Rename" },
        ["<F6>"] = { ":IncRename ", "Rename (Fancy)" },
        ["K"] = { vim.lsp.buf.hover, "Documentation" },
        ["gP"] = { vim.diagnostic.goto_prev, "Diagnostic previous" },
        ["gN"] = { vim.diagnostic.goto_next, "Diagnostic next" },
        ["gD"] = { vim.lsp.buf.declaration, "Go declaration" },
        ["gi"] = { vim.lsp.buf.implementation, "Go implementation" },
        ["gd"] = { require('telescope.builtin').lsp_definitions, "Go definitions" },
        ["gr"] = { require('telescope.builtin').lsp_references, "Go references" },
        ["<leader>b"] = { ":Git blame", "Git Blame" },
        ["<leader>D"] = { require('gitsigns').toggle_deleted, "Git show deleted" },
        ["<leader>o"] = {
            function()
                local cb = require('gitlinker.actions').open_in_browser
                require('gitlinker').get_buf_range_url('n', { action_callback = cb })
            end,
            "Open in GitHub"
        },
        ["<leader>d"] = { function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, "Diagnostics" },
        ["<leader>c"] = { require('telescope.builtin').git_commits, "Git commit" },
        --["<leader>f"] = { require('telescope.builtin').find_files, "find" },
        ["<leader>g"] = { require('telescope.builtin').live_grep, "Grep" },
        ["<leader>k"] = { require('telescope.builtin').keymaps, "Keymaps" },
        --["<leader>fb"] = { require('telescope.builtin').buffers, "buffer" },
        ["<leader>h"] = { require('telescope.builtin').help_tags, "help tags" },
        --["<leader>n"] = { require('dropbar.api').pick, "dropbar" },
        ["<leader>e"] = { require("telescope").extensions.file_browser.file_browser,
            "File browser" },
        ["<leader>a"] = { require("actions-preview").code_actions, "Code action" },
        ["<leader>A"] = { vim.lsp.buf.code_action, "Code action" },
        --["<S-left>"] = { "<CMD>BufferLineCycleWindowlessPrev<CR>", "Buffer previous" },
        --["<S-right>"] = { "<CMD>BufferLineCycleWindowlessNext<CR>", "Buffer next" },
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
