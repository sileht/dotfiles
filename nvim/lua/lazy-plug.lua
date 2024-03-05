require("lazy").setup({
    { "nvim-lua/plenary.nvim",       priority = 10000 },
    { 'nvim-tree/nvim-web-devicons', opts = { default = true } },
    {
        "rebelot/kanagawa.nvim",
        config = function()
            require('kanagawa').setup({
                overrides = function(colors)
                    return {
                        DiagnosticVirtualTextError = {
                            fg = colors.palette.samuraiRed,
                            bg = colors.palette.winterRed,
                            italic = true
                        },
                        DiagnosticVirtualTextWarn = {
                            fg = colors.palette.roninYellow,
                            bg = colors.palette.winterYellow,
                            italic = true
                        },

                        DiagnosticVirtualTextInfo = {
                            fg = colors.palette.dragonBlue,
                            bg = colors.palette.waveBlue2,
                            italic = true
                        },

                        DiagnosticVirtualTextHint = {
                            fg = colors.palette.dragonGreen,
                            bg = colors.palette.winterGreen,
                            italic = true
                        },

                    }
                end,
            })
            vim.cmd("colorscheme kanagawa-wave")
        end
    },
    -- keybinding
    { "folke/which-key.nvim",     config = function() require("keybindings") end },
    -- . on steroid
    "tpope/vim-repeat",
    -- Git blame, ...
    "tpope/vim-fugitive",
    -- screen/tmux keys fix
    "nacitar/terminalkeys.vim",
    -- easyalign ley: ga
    "junegunn/vim-easy-align",
    -- lsp smart rename F5
    { "smjonas/inc-rename.nvim",  opts = {} },
    -- comment/uncoment: gcc, gcb
    { "numToStr/Comment.nvim",    opts = {} },
    -- open in browser
    { "ruifm/gitlinker.nvim",     opts = { mappings = nil }, },
    -- git info
    { "lewis6991/gitsigns.nvim",  opts = {} },
    -- scrollbar
    { "dstein64/nvim-scrollview", opts = { signs_on_startup = {}, winblend = 50 } },
    -- TODO/NOTE colors
    { "folke/todo-comments.nvim", opts = { signs = false } },

    -- for lsp reporting right bottom
    { "j-hui/fidget.nvim",        opts = {} },
    -- lsp diagnostics bottom right
    {

        'santigo-zero/right-corner-diagnostics.nvim',
        opts = {
            position = 'bottom',
            auto_cmds = true,
        },
    },
    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        config = function() require("statusline") end
    },
    -- search and popup for everything
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build =
                'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
            },
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
            require("telescope").load_extension("file_browser")
        end
    },
    -- lsp, completion, fixer and linter
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "nvimtools/none-ls.nvim",
                dependencies = {
                    "nvimtools/none-ls-extras.nvim",
                    'MunifTanjim/prettier.nvim',
                },
            },
            -- completions on steroid
            {
                "hrsh7th/nvim-cmp",
                dependencies = {
                    "hrsh7th/cmp-cmdline",
                    "hrsh7th/cmp-buffer",
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-nvim-lsp",
                    "hrsh7th/cmp-nvim-lsp-signature-help",
                    "onsails/lspkind-nvim",
                    "lukas-reineke/cmp-under-comparator",
                    {
                        "zbirenbaum/copilot-cmp",
                        dependencies = {
                            "zbirenbaum/copilot.lua",
                        },
                    },
                },
                config = function() require("completions") end
            },
        },
        config = function() require("lsp") end
    },
    -- treesitter (for lsp detailled definitions, advanced syntax highlight)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdateSync",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-context",
                opts = {
                    separator = " ",
                }
            },
            "nvim-treesitter/nvim-treesitter-textobjects",
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
        end
    },

})
