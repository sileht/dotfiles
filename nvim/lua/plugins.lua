vim.cmd([[packadd packer.nvim]])
return require('packer').startup({
    function(use)
        use 'wbthomason/packer.nvim'

        use {'chriskempson/base16-vim', config = function()
            vim.g.base16colorspace = 256
            if vim.fn.filereadable(vim.fn.expand("~/.vimrc_background")) ~= 0 then
                vim.cmd("source ~/.vimrc_background")
            else
                vim.cmd("colorscheme base16-eighties")
            end
            vim.cmd("hi cursorlinenr cterm=none")
        end
        }

        use {'kdheepak/tabline.nvim',
            requires = {
                {'nvim-lualine/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons'}},
                {'kyazdani42/nvim-web-devicons'},
            },
            config = function()
                require('tabline').setup({enable = false})
                require('lualine').setup({
                    sections = {
                        lualine_c = {
                            require("tabline").tabline_buffers,
                            require("tricks_and_tips").status,
                        },
                    },
                    inactive_sections = {
                        lualine_a = {'mode'},
                        lualine_b = {'branch', 'diff', 'diagnostics'},
                        lualine_c = {
                            require("tabline").tabline_buffers,
                            require("tricks_and_tips").status,
                        },
                        lualine_x = {'encoding', 'fileformat', 'filetype'},
                        lualine_y = {'progress'},
                        lualine_z = {'location'}
                    },
                })
            end
        }

        -- no jump when qf/loc open
    --[[
        use {
            "luukvbaal/stabilize.nvim",
            config = function()
                require("stabilize").setup({
                    nested = "QuickFixCmdPost,DiagnosticChanged *"
                })
            end
        }
        -- smooth scroll
        use 'psliwka/vim-smoothie'
    ]]--

        -- sudo
        use 'lambdalisue/suda.vim'

        -- screen/tmux keys fix
        use 'nacitar/terminalkeys.vim'

        -- easyalign ga
        use 'junegunn/vim-easy-align'

        -- syntax colors
        use { 'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            config = function()
                require('nvim-treesitter.configs').setup({
                    ensure_installed = "maintained",
                    indent = {
                        enable = true,
                        disable = { "python" },
                    },
                    incremental_selection = {
                        enable = true,
                    },
                    highlight = {
                        additional_vim_regex_highlighting = true,
                        enable = true,
                    }
                })
            end
        }
        use 'nvim-treesitter/nvim-treesitter-textobjects'

        --[[
        use { 'ibhagwan/fzf-lua',
            requires = { 'kyazdani42/nvim-web-devicons' },
            config = function()
                require('fzf-lua').quickfix({ fzf_opts = {['--layout'] = 'reverse-list'} })
            end
        }
        ]]--

        -- auto hlsearch
        use 'romainl/vim-cool'

        -- find/grep/files/... <leader>pX
        --[[
        use { 'nvim-telescope/telescope.nvim',
            requires = { {'nvim-lua/plenary.nvim'} },
            config = function()
                require('telescope').setup()
            end
        }
        ]]--
        -- lsp, completion, fixer and linter
        use { 'neovim/nvim-lspconfig',
            requires = {
                -- completion
                { 'hrsh7th/nvim-cmp',
                    requires = {
                        { 'hrsh7th/cmp-nvim-lsp' },
                        { 'hrsh7th/cmp-buffer' },
                        { 'hrsh7th/cmp-path' },
                        { 'hrsh7th/cmp-cmdline' },
                    }
                },
                -- cli fixer, linter
                {
                    "jose-elias-alvarez/null-ls.nvim",
                    requires = { "nvim-lua/plenary.nvim" },
                },
                {
                    "onsails/lspkind-nvim",
                },
            },
            config = function()
                require("lsp")
                require("linear_cmp_source")
                local cmp = require('cmp')
                cmp.setup({
                    sources = cmp.config.sources({
                        { name = 'nvim_lsp' },
                        { name = 'buffer' },
                        { name = 'path' },
                        { name = 'linear' },
                        { name = 'cmdline' },
                    }),
                    formatting = {
                        format = require('lspkind').cmp_format({
                            with_text = false, -- do not show text alongside icons
                            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

                            -- The function below will be called before any actual modifications from lspkind
                            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                            before = function (_, vim_item)
                                return vim_item
                            end
                        })
                    }
                })
                cmp.setup.cmdline('/', {sources = {{ name = 'buffer' }}})
                cmp.setup.cmdline(':', {sources = cmp.config.sources({{ name = 'path' }}, {{ name = 'cmdline' }})})
            end
        }

        -- explorer
        use 'preservim/nerdtree'

        -- git info
        use { 'lewis6991/gitsigns.nvim',
            config = function()
                require('gitsigns').setup()
            end
        }

        -- spell
        use {'lewis6991/spellsitter.nvim',
            config = function()
                require('spellsitter').setup()
            end
        }
        use 'dstein64/nvim-scrollview'
    end,
})
