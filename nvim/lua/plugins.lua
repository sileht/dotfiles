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
        end
        }


        use 'kyazdani42/nvim-web-devicons'

        use {'nvim-lualine/lualine.nvim',
            requires = {'kyazdani42/nvim-web-devicons', opt = true},
            config = function()
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
        use {'kdheepak/tabline.nvim',
            requires = {
                { 'nvim-lualine/lualine.nvim', opt=true },
                {'kyazdani42/nvim-web-devicons', opt = true}
            },
            config = function() require('tabline').setup({enable = false}) end
        }

        -- smooth scroll
        use 'psliwka/vim-smoothie'

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

        -- auto hlsearch
        use 'romainl/vim-cool'

        -- find/grep/files/... <leader>pX
        use { 'nvim-telescope/telescope.nvim',
            requires = { {'nvim-lua/plenary.nvim'} },
            config = function()
                require('telescope').setup()
            end
        }

        -- fancy diagnostic
        use {'folke/trouble.nvim',
            config = function()
                vim.diagnostic.config({virtual_text = true, sign = true, underline = false})
                require("trouble").setup({
                    height = 6,
                    use_diagnostic_signs = true,
                    group = false,
                    padding = false,
                    auto_open = true,
                    auto_close = true,
                    mode = "document_diagnostics",
                })
            end
        }

        -- diag colors
        use 'folke/lsp-colors.nvim'

        -- fixer and linter
        use 'jose-elias-alvarez/null-ls.nvim'

        -- completion
        vim.g.coq_settings = {
            auto_start = 'shut-up',
            clients = {
                snippets = {
                    enabled = false,
                },
            }
        }

        use { 'ms-jpq/coq_nvim',
            branch = 'coq',
            run = ":COQdeps",
            requires = {
                { "ms-jpq/coq.thirdparty",
                    config = function()
                        require("coq_3p") {
                            { src = "nvimlua", short_name = "nLUA" },
                            { src = "copilot", short_name = "COP", tmp_accept_key = "<c-r>" },
                        }
                    end
                },
                {'ms-jpq/coq.artifacts', branch = 'artifacts' }
            },
        }

        -- lsp
        use { 'neovim/nvim-lspconfig',
            requires = {'ms-jpq/coq_nvim', "jose-elias-alvarez/null-ls.nvim"},
            config = function()
                require("lsp")
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
        use '~/workspace/sileht/vim-linear/'

    end,
})
