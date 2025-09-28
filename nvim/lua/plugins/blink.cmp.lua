-- completions on steroid
--
return {
    "Saghen/blink.cmp",
    version = '*',
    dependencies = {
        "moyiz/blink-emoji.nvim",
        'disrupted/blink-cmp-conventional-commits',
        "fang2hou/blink-copilot",
    },
    opts = {
        keymap = {
            preset = 'enter',
            ['<Tab>'] = { 'select_next', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
        },
        cmdline = {
            enabled = false,
        },

        signature = {
            enabled = true,
            window = {
                border = 'rounded',
            },
        },
        completion = {
            menu = {
                border = 'rounded',
                draw = { treesitter = { 'lsp' } },
                max_height = 15,
            },
            documentation = { window = { border = 'single' } },
            --ghost_text = { enabled = true },
            trigger = {
                --show_on_blocked_trigger_characters = { ":" },
                --show_on_blocked_trigger_characters = { " ", "\n", "\t", ":" },
            },
            list = {
                selection = {
                    preselect = function(ctx) return ctx.mode ~= 'cmdline' end,
                    --auto_insert = function(ctx) return ctx.mode ~= 'cmdline' end
                    auto_insert = true,
                }
            }
        },
        sources = {
            per_filetype = {
                gitcommit = { "conventional_commits", "linear", "path", "emoji", "buffer" },
            },
            default = { 'lsp', 'copilot', 'path', 'buffer' },
            providers = {
                lsp = {
                },
                conventional_commits = {
                    name = 'Conventional Commits',
                    module = 'blink-cmp-conventional-commits',
                    enabled = function()
                        return vim.bo.filetype == 'gitcommit'
                    end,
                    opts = {}, -- none so far
                },
                emoji = {
                    module = "blink-emoji",
                    name = "Emoji",
                    score_offset = 15,        -- Tune by preference
                    opts = { insert = true }, -- Insert emoji (default) or complete its name
                },
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    --score_offset = 10,
                    async = true,
                    opts = {
                        max_completions = 3,
                    },
                },
                linear = {
                    module = "blink-cmp-linear",
                    name = "linear",
                    async = true,
                }
            }
        },
    }
}
