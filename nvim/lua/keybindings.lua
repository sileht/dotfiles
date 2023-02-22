require("which-key").setup()
require("which-key").register(
    {
        ["<F10>"] = { function() require('utils').toggle_formatter() end, "Toggle FormatWrite" },
        ["<F11>"] = { ":set spell!<cr>", "Toggle spell" },
        ["<F12>"] = { function() require('utils').toggle_focus() end, "Show/Hide keybindings" },
        ["<C-k>"] = { function() vim.lsp.buf.signature_help() end, "Show signature" },
        ["<F5>"] = { function() vim.lsp.buf.rename() end, "Rename" },
        ["K"] = { function() vim.lsp.buf.hover() end, "Documentation" },
        ["gP"] = { function() vim.diagnostic.goto_prev() end, "Diagnostic previous" },
        ["gN"] = { function() vim.diagnostic.goto_next() end, "Diagnostic next" },
        ["gD"] = { function() vim.lsp.buf.declaration() end, "Go declaration" },
        ["gi"] = { function() vim.lsp.buf.implementation() end, "Go implementation" },
        ["<leader>sr"] = { function() require('ssr').open() end, "SSR", mode = { "n", "x" } },
        ["gd"] = { function() require('telescope.builtin').lsp_definitions() end, "Go definitions" },
        ["gr"] = { function() require('telescope.builtin').lsp_references() end, "Go references" },
        ["<leader>gb"] = { function() require('gitsigns').blame_line({ full = true }) end, "Git Blame" },
        ["<leader>gd"] = { function() require('gitsigns').toggle_deleted() end, "Git show deleted" },
        ["<leader>gy"] = {
            function()
                local cb = require('gitlinker.actions').open_in_browser
                require('gitlinker').get_buf_range_url('n', { action_callback = cb })
            end,
            "Open line in browser"
        },
        ["<leader>d"] = { function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, "Telescope diagnostics" },
        ["<leader>fp"] = { function() require('telescope.builtin').builtin() end, "Telescope builtin" },
        ["<leader>fc"] = { function() require('telescope.builtin').git_commits() end, "Telescope git commit" },
        ["<leader>fs"] = { function() require('telescope.builtin').lsp_document_symbols() end, "Telescope symbols" },
        ["<leader>fd"] = { function() require('telescope.builtin').lsp_type_definitions() end, "Telescope type definitions" },
        ["<leader>ff"] = { function() require('telescope.builtin').find_files() end, "Telescope find" },
        ["<leader>fg"] = { function() require('telescope.builtin').live_grep() end, "Telescope grep" },
        ["<leader>fb"] = { function() require('telescope.builtin').buffers() end, "Telescope buffer" },
        ["<leader>fh"] = { function() require('telescope.builtin').help_tags() end, "Telescope help tags" },
        ["<leader>D"] = { function() vim.lsp.buf.type_definition() end, "Type definition" },
        ["<leader>ca"] = { function() vim.lsp.buf.code_action() end, "Code action" },
        ["<leader>k"] = { "" },
        ["<leader>e"] = { ":RnvimrToggle <cr>", "Explorer" }
    }
)
vim.cmd([[
    nnoremap P "0p                            " Paste last yank
    nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
    cnoreabbrev bd :lua require('utils').buffer_delete_workaround()
    nmap <silent> <S-left>  :bp<Enter>
    nmap <silent> <S-right> :bn<Enter>
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)
    cmap w!! :w suda://%<CR>:e!<CR>
]])
