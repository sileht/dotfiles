require("lazy").setup({
    { "nvim-lua/plenary.nvim",       priority = 10000 },
    { 'nvim-tree/nvim-web-devicons', opts = { default = true } },
    {
        "bluz71/vim-moonfly-colors",
        name = "moonfly",
        lazy = false,
        priority = 1000,
        config = function()
            vim.opt.background = "dark"
            vim.cmd('colorscheme moonfly')
        end
    },
    -- keybinding
    { "folke/which-key.nvim",   config = function() require("keybindings") end },
    -- . on steroid
    "tpope/vim-repeat",
    -- Git blame, ...
    -- "tpope/vim-fugitive",
    { "FabijanZulj/blame.nvim", opts = {} },
    {
        "NeogitOrg/neogit",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "sindrets/diffview.nvim",        -- optional - Diff integration
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = true,
    },
    {
        'akinsho/git-conflict.nvim', version = "*", opts = {},
    },
    -- Change case crX with X c,d,k,n,P,s,U,/
    { "gregorias/coerce.nvim",   opts = {} },
    -- shiny cursor move
    {
        "sphamba/smear-cursor.nvim",
        opts = {},
    },
    -- Better f/F/t/T
    "rhysd/clever-f.vim",
    -- gpr/gpd (goto preview references/definitions)
    {
        "rmagatti/goto-preview",
        event = "BufEnter",
        opts = {}
    },
    {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        },
        opts = {
            openai_params = {
                model = "o1-mini"
            },
            api_key_cmd = "security find-generic-password -w -s ENV_OPENAI_TOKEN"
        }
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
            { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
        },
        build = "make tiktoken",          -- Only on MacOS or Linux
        opts = {
            prompts = {
            }
        },
    },
    {
        "danielfalk/smart-open.nvim",
        branch = "0.2.x",
        config = function()
            require("telescope").load_extension("smart_open")
        end,
        dependencies = {
            "kkharji/sqlite.lua",
            -- Only required if using match_algorithm fzf
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
            { "nvim-telescope/telescope-fzy-native.nvim" },
        },
    },
    -- file browser
    {
        "rolv-apneseth/tfm.nvim",
        opts = {},
    },
    -- screen/tmux keys fix
    "nacitar/terminalkeys.vim",
    -- easyalign ley: ga
    "junegunn/vim-easy-align",
    --
    {
        "mizlan/iswap.nvim",
    },
    --
    -- lsp smart rename F5
    {
        'gelguy/wilder.nvim',
        dependencies = {
            "romgrk/fzy-lua-native"
        },
        config = function()
            local wilder = require('wilder')
            wilder.setup({ modes = { ':', '/', '?' } })
            wilder.set_option('renderer', wilder.popupmenu_renderer(
                {
                    highlights = {
                        accent = wilder.make_hl('WilderAccent', 'Pmenu',
                            { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
                    },
                    highlighter = { wilder.lua_fzy_highlighter() },
                    left = { ' ', wilder.popupmenu_devicons() },
                    right = { ' ', wilder.popupmenu_scrollbar() },
                }
            ))
        end,
    },
    { "smjonas/inc-rename.nvim", opts = {} },
    -- comment/uncoment: gcc, gcb
    { "numToStr/Comment.nvim",   opts = {} },
    -- open in browser
    { "ruifm/gitlinker.nvim",    opts = { mappings = nil }, },
    -- git info
    { "lewis6991/gitsigns.nvim", opts = {} },
    -- scrollbar
    {
        "dstein64/nvim-scrollview",
        opts = { signs_on_startup = {}, winblend = 50 }
    },
    { "karb94/neoscroll.nvim",    opts = {} },
    -- TODO/NOTE colors
    { "folke/todo-comments.nvim", opts = { signs = false } },
    --
    -- statusline-- with extras
    {
        "nvim-lualine/lualine.nvim",
        config = function() require("statusline") end
    },
    -- tabline
    {
        'romgrk/barbar.nvim',
        dependencies = {
            'lewis6991/gitsigns.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            maximum_padding = 1,
            insert_at_end = true,
            icons = {
                button = '⛌',
                buffer_number = "superscript",
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true },
                    [vim.diagnostic.severity.WARN] = { enabled = true },
                    [vim.diagnostic.severity.INFO] = { enabled = true },
                    [vim.diagnostic.severity.HINT] = { enabled = true },
                },
            }
        },
    },
    { 'Bekaboo/deadcolumn.nvim',      opts = {} },
    -- for lsp reporting right bottom
    { "j-hui/fidget.nvim",            opts = {} },
    -- Fast motion w, e, b
    { "chrisgrieser/nvim-spider",     opts = {} },
    -- Better code actions UI
    { "aznhe21/actions-preview.nvim", opts = {} },
    -- Indentation marker
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "⠅" },
            scope = { enabled = false },
        },
    },
    -- lsp diagnostics bottom right
    {
        'santigo-zero/right-corner-diagnostics.nvim',
        opts = {
            position = 'bottom',
            auto_cmds = true,
        },
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
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
                {
                    "nvimtools/none-ls.nvim",
                    build = "git cherry-pick c2ad56b",
                    dependencies = {
                        "nvimtools/none-ls-extras.nvim",
                        'MunifTanjim/prettier.nvim',
                    },
                }
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
                "nvim-treesitter/nvim-treesitter-textobjects",
                enabled = false,
            }
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
    }
})
