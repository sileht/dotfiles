require("lazy").setup({
    { "nvim-lua/plenary.nvim",   priority = 10000 },

    {
        'nvim-tree/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup({
                default = true,
            })
        end
    },
    {
        "mhartington/oceanic-next",
        config = function()
            vim.cmd("colorscheme OceanicNext")
        end
    },
    "jubnzv/virtual-types.nvim",
    "mfussenegger/nvim-lint",
    "tpope/vim-repeat",
    "tpope/vim-fugitive",
    "cshuaimin/ssr.nvim",
    -- "ziontee113/syntax-tree-surfer",
    "kevinhwang91/rnvimr",
    { 'akinsho/toggleterm.nvim', opts = { terminal_mappings = true, insert_mappings = true } },
    "lambdalisue/suda.vim",                                                          -- sudo
    "nacitar/terminalkeys.vim",                                                      -- screen/tmux keys fix
    "junegunn/vim-easy-align",                                                       -- easyalign ley: ga
    { "numToStr/Comment.nvim",    opts = {} },                                       -- fast comment
    { "ruifm/gitlinker.nvim",     opts = { mappings = nil }, },                      -- open in browser
    { "lewis6991/gitsigns.nvim",  opts = {} },                                       -- git info
    { "dstein64/nvim-scrollview", opts = { signs_on_startup = {}, winblend = 50 } }, -- scrollbar
    { "folke/which-key.nvim",     config = function() require("keybindings") end },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-lua/lsp-status.nvim",
            { "j-hui/fidget.nvim", branch = "legacy" }
        },
        config = function() require("statusline") end
    },
    -- syntax colors
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdateSync",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "romgrk/nvim-treesitter-context"
        },
        config = function()
            require("nvim-treesitter.configs").setup(
                {
                    ensure_installed = "all",
                    ignore_install = { "phpdoc", "wgsl" },
                    indent = { enable = true },
                    incremental_selection = { enable = true },
                    highlight = { enable = true, additional_vim_regex_highlighting = true },
                    textobjects = {
                        select = {
                            enable = true,
                            -- Automatically jump forward to textobj, similar to targets.vim
                            lookahead = true,
                            keymaps = {
                                ["af"] = "@function.outer",
                                ["if"] = "@function.inner",
                                ["ac"] = "@class.outer",
                                ["ic"] = "@class.inner"
                            }
                        }
                    }
                }
            )
            require("treesitter-context").setup({ enable = true, max_lines = 3 })
        end
    },

    -- find/grep/files/... <leader>pX
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "aaronhallaert/ts-advanced-git-search.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            local defaults = require("telescope.themes").get_ivy({})
            defaults.prompt_prefix = " ❯ "
            defaults.selection_caret = " ❯ "
            defaults.entry_prefix = "   "
            defaults.find_command = { "fd", "-t=f", "-a" }
            defaults.path_display = { "smart" }
            defaults.wrap_results = true
            require("telescope").setup({ defaults = defaults })
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("advanced_git_search")
            require("telescope").load_extension("file_browser")
            require("telescope").load_extension("ui-select")
        end
    },
    { "smjonas/inc-rename.nvim", opts = {} },

    {
        "zbirenbaum/copilot.lua",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = true },
            filetypes = {
                javascript = true,
                typescript = true,
                python = true,
                ["*"] = false,
            },
        }
    },

    -- lsp, completion, fixer and linter
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "nvimtools/none-ls.nvim",
            --"jose-elias-alvarez/null-ls.nvim",
            {
                "hrsh7th/nvim-cmp",
                dependencies = {
                    "hrsh7th/cmp-cmdline",
                    "hrsh7th/cmp-vsnip",
                    "hrsh7th/vim-vsnip",
                    "hrsh7th/cmp-buffer",
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-nvim-lsp",
                    "hrsh7th/cmp-nvim-lsp-document-symbol",
                    "hrsh7th/cmp-nvim-lsp-signature-help",
                    "petertriho/cmp-git",
                    "onsails/lspkind-nvim",
                    "lukas-reineke/cmp-under-comparator",
                    {
                        "zbirenbaum/copilot-cmp",
                        dependencies = { "zbirenbaum/copilot.lua" },
                    },
                },
                config = function() require("completions") end
            },
        },
        config = function() require("lsp") end
    },
    { "folke/lsp-colors.nvim",   opts = {} },
    {
        "folke/trouble.nvim",
        build = ";git cherry-pick custom",
        config = function()
            require("trouble").setup(
                {
                    auto_open = false,
                    auto_close = false,
                    group = false,
                    height = 5,
                    padding = false,
                    indent_lines = false,
                    mode = "workspace_diagnostics",
                    auto = false,
                    use_diagnostic_signs = true,
                }
            )

            local valid_display = function()
                local is_headless = next(vim.api.nvim_list_uis()) == nil
                local win = vim.api.nvim_get_current_win()
                local buf = vim.api.nvim_get_current_buf()
                local already_done = vim.g.trouble_init_done and vim.g.trouble_init_done == 1
                return not is_headless and not already_done and vim.api.nvim_buf_is_valid(buf) and
                    vim.api.nvim_win_is_valid(win)
            end
            if valid_display() then
                vim.g.trouble_init_done = 1
                require("trouble").open({ auto = false })
            end
        end
    },
    { 'antonk52/bad-practices.nvim', opts = {} }
})
