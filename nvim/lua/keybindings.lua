require("which-key").setup()

function open_in_browser()
    local cb = require('gitlinker.actions').open_in_browser
    require('gitlinker').get_buf_range_url('n', { action_callback = cb })
end

require("which-key").add(
    {
        { "<F10>",      require('formatter').toggle,                                            desc = "Toggle FormatWrite" },
        { "<F11>",      ":set spell!<cr>",                                                      desc = "Toggle spell" },
        { "<F12>",      require('utils').toggle_focus,                                          desc = "Show/Hide keybindings" },
        { "<C-k>",      vim.lsp.buf.signature_help,                                             desc = "Show signature" },
        { "<F5>",       vim.lsp.buf.rename,                                                     desc = "Rename" },
        { "<F6>",       ":IncRename ",                                                          desc = "Rename (Fancy)" },
        { "K",          vim.lsp.buf.hover,                                                      desc = "Documentation" },
        { "gP",         vim.diagnostic.goto_prev,                                               desc = "Diagnostic previous" },
        { "gN",         vim.diagnostic.goto_next,                                               desc = "Diagnostic next" },
        { "gD",         vim.lsp.buf.declaration,                                                desc = "Go declaration" },
        { "gi",         vim.lsp.buf.implementation,                                             desc = "Go implementation" },
        { "gs",         ":ISwap<CR>",                                                           desc = "Swap function arguments" },
        { "gd",         require('telescope.builtin').lsp_definitions,                           desc = "Go definitions" },
        { "gr",         require('telescope.builtin').lsp_references,                            desc = "Go references" },
        { "gpd",        require('goto-preview').goto_preview_definition,                        desc = "Preview definition" },
        { "gpr",        require('goto-preview').goto_preview_references,                        desc = "Preview references" },
        { "gpc",        require('goto-preview').close_all_win,                                  desc = "Closes Previews" },
        --{ "<leader>b", ":Git blame",                                                           desc = "Git Blame" },
        { "<leader>b",  ":BlameToggle window<CR>",                                              desc = "Git Blame" },
        { "<leader>D",  require('gitsigns').toggle_deleted,                                     desc = "Git show deleted" },
        { "<leader>o",  open_in_browser,                                                        desc = "Open in GitHub" },
        { "<leader>d",  function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, desc = "Diagnostics" },
        --{ "<leader>c", require('telescope.builtin').git_commits,                               desc = "Git commit" },
        { "<leader>cc", "<cmd>ChatGPT<CR>",                                                     mode = { "n", "v" },             desc = "ChatGPT - ChatGPT" },
        { "<leader>ce", "<cmd>ChatGPTEditWithInstruction<CR>",                                  mode = { "n", "v" },             desc = "ChatGPT - Edit with instruction" },
        { "<leader>cg", "<cmd>ChatGPTRun grammar_correction<CR>",                               mode = { "n", "v" },             desc = "ChatGPT - Grammar Correction" },
        { "<leader>ct", "<cmd>ChatGPTRun translate<CR>",                                        mode = { "n", "v" },             desc = "ChatGPT - Translate" },
        { "<leader>ck", "<cmd>ChatGPTRun keywords<CR>",                                         mode = { "n", "v" },             desc = "ChatGPT - Keywords" },
        { "<leader>cd", "<cmd>ChatGPTRun docstring<CR>",                                        mode = { "n", "v" },             desc = "ChatGPT - Docstring" },
        { "<leader>ca", "<cmd>ChatGPTRun add_tests<CR>",                                        mode = { "n", "v" },             desc = "ChatGPT - Add Tests" },
        { "<leader>co", "<cmd>ChatGPTRun optimize_code<CR>",                                    mode = { "n", "v" },             desc = "ChatGPT - Optimize Code" },
        { "<leader>cs", "<cmd>ChatGPTRun summarize<CR>",                                        mode = { "n", "v" },             desc = "ChatGPT - Summarize" },
        { "<leader>cf", "<cmd>ChatGPTRun fix_bugs<CR>",                                         mode = { "n", "v" },             desc = "ChatGPT - Fix Bugs" },
        { "<leader>cx", "<cmd>ChatGPTRun explain_code<CR>",                                     mode = { "n", "v" },             desc = "ChatGPT - Explain Code" },
        { "<leader>cr", "<cmd>ChatGPTRun roxygen_edit<CR>",                                     mode = { "n", "v" },             desc = "ChatGPT - Roxygen Edit" },
        { "<leader>cl", "<cmd>ChatGPTRun code_readability_analysis<CR>",                        mode = { "n", "v" },             desc = "ChatGPT - Code Readability Analysis" },
        --{ "<leader>f", require('telescope.builtin').find_files, desc = "find" },
        { "<leader>f",  require('telescope.builtin').git_files,                                 desc = "Git files" },
        { "<leader>g",  require('telescope.builtin').live_grep,                                 desc = "Grep" },
        { "<leader>k",  require('telescope.builtin').keymaps,                                   desc = "Keymaps" },
        --{ "<leader>fb", require('telescope.builtin').buffers, desc = "buffer" },
        { "<leader>h",  require('telescope.builtin').help_tags,                                 desc = "help tags" },
        --{ "<leader>n", require('dropbar.api').pick, desc = "dropbar" },
        {
            "<leader>e",
            --require("telescope").extensions.file_browser.file_browser,
            require("tfm").open,
            desc =
            "File browser"
        },
        { "<leader>a", require("actions-preview").code_actions, desc = "Code action" },
        { "<leader>A", vim.lsp.buf.code_action,                 desc = "Code action" },
        { "<S-left>",  ":BufferPrevious<CR>",                   desc = "Buffer previous" },
        { "<S-right>", ":BufferNext<CR>",                       desc = "Buffer next" },
        { ";",         "<Plug>(clever-f-reset)",                desc = "clever-f-reset" },
        {
            "<leader>zh",
            function()
                local actions = require("CopilotChat.actions")
                require("CopilotChat.integrations.telescope").pick(actions.help_actions())
            end,
            desc = "CopilotChat - Help actions",
        },
        {
            "<leader>zp",
            function()
                local actions = require("CopilotChat.actions")
                require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
            end,
            desc = "CopilotChat - Prompt actions",
        },

        {
            "<leader>zo",
            function()
                local chat = require("CopilotChat")
                chat.open()
            end,
            desc = "CopilotChat - Prompt actions",
        },
        {
            "<leader>zz",
            function()
                local input = vim.fn.input("Quick Chat: ")
                if input ~= "" then
                    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
                end
            end,
            desc = "CopilotChat - Quick chat",
        }
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
    command GitBlame BlameToggle
    command Blame BlameToggle
]])
