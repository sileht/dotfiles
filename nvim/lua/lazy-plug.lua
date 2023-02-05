require("lazy").setup({
    { "nvim-lua/plenary.nvim", priority = 10000 },
    { "nvim-tree/nvim-web-devicons", priority = 10000 },

    { 'mhartington/oceanic-next', config = function() vim.cmd("colorscheme OceanicNext") end },
    -- { "folke/tokyonight.nvim", config = function() vim.cmd("colorscheme tokyonight") end }

    "Raimondi/delimitMate",
    "tpope/vim-repeat",
    'tpope/vim-fugitive',
    "kevinhwang91/rnvimr", -- ranger, key: Alt+E
    'ggandor/lightspeed.nvim', -- fast job, key: s
    "lambdalisue/suda.vim", -- sudo
    "nacitar/terminalkeys.vim", -- screen/tmux keys fix
    "junegunn/vim-easy-align", -- easyalign ley: ga
    { "numToStr/Comment.nvim", config = true }, -- fast comment
    { "phaazon/hop.nvim", config = true },
    { "ruifm/gitlinker.nvim", config = { mappings = nil } }, -- LSP progress bar handler

    { "lewis6991/gitsigns.nvim", config = true }, -- git info
    "dstein64/nvim-scrollview", -- scrollbar
    {
        "folke/which-key.nvim",
        dependencies = "mrjones2014/legendary.nvim",
        config = function()
            require("keybindings").setup_legacy_key()
            require("legendary").setup()
            require("keybindings").setup_which_key()
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            {
                "nvim-lua/lsp-status.nvim",
                config = function()
                    require("lsp-status").register_progress()
                end
            }
        },
        config = function()
            local sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = {
                    { "filename" },
                    -- require("tricks_and_tips").status,
                    require "lsp-status".status
                },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" }
            }
            require("lualine").setup(
                {
                    sections = sections,
                    inactive_sections = sections,
                    tabline = {
                        lualine_a = { "buffers" },
                        lualine_b = {},
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = { "tabs" }
                    }
                }
            )
        end
    },



    -- syntax colors
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdateSync",
        dependencies = {
            "p00f/nvim-ts-rainbow",
            "nvim-treesitter/nvim-treesitter-textobjects",
            "romgrk/nvim-treesitter-context"
        },
        config = function()
            require("nvim-treesitter.configs").setup(
                {
                    ensure_installed = "all",
                    ignore_install = { "phpdoc", "wgsl" },
                    indent = {
                        enable = true
                        -- disable = {"python"}
                    },
                    incremental_selection = {
                        enable = true
                    },
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = true
                    },
                    rainbow = {
                        enable = true,
                        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                        max_file_lines = nil -- Do not enable for files with more than n lines, int
                    },
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
            require("treesitter-context").setup(
                {
                    enable = true,
                    max_lines = 3
                }
            )
        end
    },

    -- find/grep/files/... <leader>pX
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
        },
        config = function()
            -- local trouble = require("trouble.providers.telescope")
            local defaults = require("telescope.themes").get_ivy({})
            -- defaults.mappings = {
            --  i = {["<c-t>"] = trouble.open_with_trouble},
            --  n = {["<c-t>"] = trouble.open_with_trouble}
            -- }
            require("telescope").setup(
                {
                    defaults = defaults
                }
            )
            require("telescope").load_extension("fzf")
        end
    },


    -- lsp, completion, fixer and linter
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- completion
            {
                "hrsh7th/nvim-cmp",
                dependencies = {
                    { "hrsh7th/cmp-buffer" },
                    { "hrsh7th/cmp-path" },
                    { "hrsh7th/cmp-cmdline" },
                    { "hrsh7th/cmp-nvim-lsp" },
                    { "hrsh7th/cmp-nvim-lsp-document-symbol" },
                    { "hrsh7th/cmp-nvim-lsp-signature-help" },
                    { "petertriho/cmp-git" },
                    -- { "f3fora/cmp-spell" },
                    { "davidsierradz/cmp-conventionalcommits" }
                    -- {"tzachar/cmp-fuzzy-buffer", dependencies = {"tzachar/fuzzy.nvim"}}
                }
            },
            { "onsails/lspkind-nvim" },
            { "mfussenegger/nvim-lint" },
            { "mhartington/formatter.nvim" }
        },
        config = function()
            require("lsp")
            require("post_write_tools").setup()
            -- require("linear_cmp_source")
            local cmp = require("cmp")
            cmp.setup(
                {
                    snippet = {},
                    sources = cmp.config.sources(
                        {
                            { name = "nvim_lsp" },
                            { name = "nvim_lsp_signature_help" },
                            { name = "nvim_lsp_document_symbol" },
                            { name = "buffer" },
                            { name = "path" },
                            -- { name = "spell" },
                            --  {name = "fuzzy_buffer"}
                        }
                    ),
                    formatting = {
                        format = require("lspkind").cmp_format(
                            {
                                with_text = false, -- do not show text alongside icons
                                maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                                -- The function below will be called before any actual modifications from lspkind
                                -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                                before = function(_, vim_item)
                                    return vim_item
                                end
                            }
                        )
                    },
                    mapping = cmp.mapping.preset.insert(
                        {
                            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                            ["<C-f>"] = cmp.mapping.scroll_docs(4),
                            ["<C-space>"] = cmp.mapping.complete(),
                            ["<C-e>"] = cmp.mapping.abort(),
                            ["<CR>"] = cmp.mapping.confirm {
                                --behavior = cmp.ConfirmBehavior.Replace,
                                select = true
                            },
                            ["<Tab>"] = cmp.mapping(
                                function(fallback)
                                    if cmp.visible() then
                                        cmp.select_next_item()
                                    else
                                        fallback()
                                    end
                                end,
                                { "i", "s" }
                            ),
                            ["<S-Tab>"] = cmp.mapping(
                                function(fallback)
                                    if cmp.visible() then
                                        cmp.select_prev_item()
                                    else
                                        fallback()
                                    end
                                end,
                                { "i", "s" }
                            )
                        }
                    )
                }
            )
            cmp.setup.filetype(
                "gitcommit",
                {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources(
                        {
                            { name = "cmp_git" },
                            { name = "conventionalcommits" },
                        },
                        {
                            { name = "buffer" },
                        }
                    )
                }
            )
            cmp.setup.cmdline(
                { "/", "?" },
                {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = { { name = "buffer" } }
                }
            )
            cmp.setup.cmdline(
                ":",
                {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
                }
            )
            require("cmp_git").setup()
        end
    },
    {
        "folke/trouble.nvim",
        dependencies = {
        },
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
                    auto = false
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
})
