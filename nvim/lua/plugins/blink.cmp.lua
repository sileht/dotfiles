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
    config = function()
        require("blink.cmp").setup({
            keymap = {
                preset = 'enter',
                ['<Tab>'] = { 'select_next', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'fallback' },
            },
            cmdline = {
                enabled = false,
            },
            sources = {
                per_filetype = {
                    codecompanion = { "codecompanion" },
                    gitcommit = { "conventional_commits", "linear", "path", "emoji", "linear" },
                },
                default = { 'copilot', 'lsp', 'path', 'buffer' },
                providers = {
                    conventional_commits = {
                        name = 'Conventional Commits',
                        module = 'blink-cmp-conventional-commits',
                        enabled = function()
                            return vim.bo.filetype == 'gitcommit'
                        end,
                        opts = {}, -- none so far
                    },
                    codecompanion = {
                        name = "CodeCompanion",
                        module = "codecompanion.providers.completion.blink",
                        async = true,
                        score_offset = 100,
                        enabled = true,
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
                        score_offset = 100,
                        async = true,
                        opts = {
                            max_completions = 3,
                        },
                    },
                    lsp = {
                        override = {
                            get_trigger_characters = function(self)
                                local trigger_characters = self:get_trigger_characters()
                                vim.list_extend(trigger_characters, { '\n', '\t', ' ' })
                                return trigger_characters
                            end
                        },
                    },
                    linear = {
                        module = "blink-cmp-linear",
                        name = "linear",
                        async = true,
                    }
                }
            },
            signature = {
                enabled = true,
                window = { border = 'single' },
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = false,
                    },
                },
                menu = {
                    border = 'single',
                    draw = { treesitter = { 'lsp' } },
                    max_height = 15,
                },
                documentation = { window = { border = 'single' } },
                ghost_text = { enabled = false },
                trigger = {
                    show_on_trigger_character = true,
                    show_on_blocked_trigger_characters = { ":" },
                },
                list = {
                    selection = {
                        preselect = function(ctx) return ctx.mode ~= 'cmdline' end,
                        --auto_insert = function(ctx) return ctx.mode ~= 'cmdline' end
                        auto_insert = true,
                    }
                }
            },
        })
    end
}
