vim.cmd([[packadd packer.nvim]])

return require("packer").startup(
  {
    function(use)
      use "wbthomason/packer.nvim"
      use "nvim-lua/plenary.nvim"

      use {
        -- "sainnhe/sonokai",
        "folke/tokyonight.nvim",
        config = function()
          vim.cmd("colorscheme tokyonight")
        end
      }

      -- Highlight arguments' definitions and usages, asynchronously, using Treesitter
      use {
        "m-demare/hlargs.nvim",
        requires = {"nvim-treesitter/nvim-treesitter"},
        config = function()
          require("hlargs").setup()
        end
      }
      use {
        "stevearc/aerial.nvim",
        config = function()
          require("aerial").setup(
            {
              on_attach = function(bufnr)
                -- Toggle the aerial window with <leader>a
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>a", "<cmd>AerialToggle!<CR>", {})
                -- Jump forwards/backwards with '{' and '}'
                vim.api.nvim_buf_set_keymap(bufnr, "n", "{", "<cmd>AerialPrev<CR>", {})
                vim.api.nvim_buf_set_keymap(bufnr, "n", "}", "<cmd>AerialNext<CR>", {})
                -- Jump up the tree with '[[' or ']]'
                vim.api.nvim_buf_set_keymap(bufnr, "n", "[[", "<cmd>AerialPrevUp<CR>", {})
                vim.api.nvim_buf_set_keymap(bufnr, "n", "]]", "<cmd>AerialNextUp<CR>", {})
              end
            }
          )
        end
      }
      use {
        "nvim-lualine/lualine.nvim",
        requires = {"kyazdani42/nvim-web-devicons"},
        config = function()
          local sections = {
            lualine_a = {"mode"},
            lualine_b = {"branch", "diff", "diagnostics"},
            lualine_c = {
              {"filename"},
              require("tricks_and_tips").status
            },
            lualine_x = {"encoding", "fileformat", "filetype"},
            lualine_y = {"progress"},
            lualine_z = {"location"}
          }
          require("lualine").setup(
            {
              sections = sections,
              inactive_sections = sections,
              tabline = {
                lualine_a = {"buffers"},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {"tabs"}
              }
            }
          )
        end
      }

      -- fast comment
      use {
        "numToStr/Comment.nvim",
        config = function()
          require("Comment").setup()
        end
      }

      -- sudo
      use "lambdalisue/suda.vim"

      -- screen/tmux keys fix
      use "nacitar/terminalkeys.vim"

      -- easyalign ga
      use "junegunn/vim-easy-align"

      use {
        "ruifm/gitlinker.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
          require("gitlinker").setup({mappings = nil})
        end
      }

      use {
        "phaazon/hop.nvim",
        config = function()
          require("hop").setup()
        end
      }

      use {
        "folke/which-key.nvim",
        requires = "mrjones2014/legendary.nvim",
        config = function()
          require("keybindings").setup_legacy_key()
          require("legendary").setup()
          require("keybindings").setup_which_key()
        end
      }

      use {
        "kosayoda/nvim-lightbulb",
        requires = "antoinemadec/FixCursorHold.nvim",
        config = function()
          require("nvim-lightbulb").setup({autocmd = {enabled = true}})
        end
      }

      -- ranger
      use "kevinhwang91/rnvimr"
      use {
        "weilbith/nvim-code-action-menu",
        cmd = "CodeActionMenu"
      }
      -- syntax colors
      use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdateSync",
        requires = {{"p00f/nvim-ts-rainbow"}},
        config = function()
          require("nvim-treesitter.configs").setup(
            {
              ensure_installed = "all",
              ignore_install = {"phpdoc", "wgsl"},
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
              }
            }
          )
        end
      }
      use "nvim-treesitter/nvim-treesitter-textobjects" -- auto hlsearch
      use {
        "romgrk/nvim-treesitter-context",
        after = {"nvim-treesitter"},
        config = function()
          require("treesitter-context").setup(
            {
              enable = true,
              throttle = true
            }
          )
        end
      }

      -- find/grep/files/... <leader>pX
      use {
        "nvim-telescope/telescope.nvim",
        requires = {
          {"nvim-lua/plenary.nvim"},
          {"nvim-telescope/telescope-fzf-native.nvim", run = "make"}
        },
        config = function()
          local trouble = require("trouble.providers.telescope")
          require("telescope").setup(
            {
              defaults = {
                mappings = {
                  i = {["<c-t>"] = trouble.open_with_trouble},
                  n = {["<c-t>"] = trouble.open_with_trouble}
                }
              },
              pickers = {
                diagnostics = {
                  theme = "dropdown",
                  layout_config = {
                    width = 300
                  }
                }
              }
            }
          )
          require("telescope").load_extension("fzf")
          require("telescope").load_extension("aerial")
        end
      }

      -- lsp, completion, fixer and linter
      use {
        "neovim/nvim-lspconfig",
        requires = {
          -- completion
          {
            "hrsh7th/nvim-cmp",
            requires = {
              {"hrsh7th/cmp-buffer"},
              {"hrsh7th/cmp-calc"},
              {"hrsh7th/cmp-path"},
              {"hrsh7th/cmp-vsnip"},
              {"hrsh7th/cmp-cmdline"},
              {"hrsh7th/cmp-emoji"},
              {"hrsh7th/cmp-nvim-lsp"},
              {"hrsh7th/cmp-nvim-lsp-document-symbol"},
              {"hrsh7th/cmp-nvim-lsp-signature-help"},
              {"petertriho/cmp-git", requires = "nvim-lua/plenary.nvim"},
              {"f3fora/cmp-spell"},
              {"davidsierradz/cmp-conventionalcommits"}
              -- {"tzachar/cmp-fuzzy-buffer", requires = {"tzachar/fuzzy.nvim"}}
            }
          },
          {
            "onsails/lspkind-nvim"
          },
          {
            "mfussenegger/nvim-lint"
          },
          {
            "mhartington/formatter.nvim"
          }
        },
        config = function()
          require("lsp")
          require("post_write_tools").setup()
          -- require("linear_cmp_source")
          local cmp = require("cmp")
          cmp.setup(
            {
              snippet = {
                expand = function(args)
                  vim.fn["vsnip#anonymous"](args.body)
                end
              },
              sources = cmp.config.sources(
                {
                  {name = "nvim_lsp"},
                  {name = "nvim_lsp_signature_help"},
                  {name = "nvim_lsp_document_symbol"},
                  {name = "vsnip"},
                  {name = "spell"},
                  {name = "buffer"},
                  {name = "path"},
                  {name = "linear"},
                  {name = "calc"},
                  {name = "emoji"}
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
                    {"i", "s"}
                  ),
                  ["<S-Tab>"] = cmp.mapping(
                    function(fallback)
                      if cmp.visible() then
                        cmp.select_prev_item()
                      else
                        fallback()
                      end
                    end,
                    {"i", "s"}
                  )
                }
              )
            }
          )
          cmp.setup.filetype(
            "gitcommit",
            {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({{name = "cmp_git"}}, {{name = "buffer"}}, {{name = "conventionalcommits"}})
            }
          )
          cmp.setup.cmdline(
            {"/", "?"},
            {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {{name = "buffer"}}
            }
          )
          cmp.setup.cmdline(
            ":",
            {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}})
            }
          )
          require("cmp_git").setup()
        end
      }

      use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
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
            require("trouble").open({auto = false})
          end
        end
      }

      -- git info
      use {
        "lewis6991/gitsigns.nvim",
        config = function()
          require("gitsigns").setup()
        end
      }

      use "dstein64/nvim-scrollview"
    end
  }
)
