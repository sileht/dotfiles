-- completions on steroid
--
return {
    "Saghen/blink.cmp",
    version = '*',
    dependencies = {
        "moyiz/blink-emoji.nvim",
        {
            "giuxtaposition/blink-cmp-copilot",
            dependencies = {
                "zbirenbaum/copilot.lua",
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                }
            }
        },
    },
    config = function()
        require("blink.cmp").setup({
            keymap = {
                preset = 'enter',
                ['<Tab>'] = { 'select_next', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'fallback' },
            },
            sources = {
                default = { 'copilot', 'lsp', 'path', 'emoji', 'buffer', 'linear' },
                providers = {
                    emoji = {
                        module = "blink-emoji",
                        name = "Emoji",
                        score_offset = 15,        -- Tune by preference
                        opts = { insert = true }, -- Insert emoji (default) or complete its name
                    },
                    copilot = {
                        name = "copilot",
                        module = "blink-cmp-copilot",
                        score_offset = 100,
                        async = true,
                        transform_items = function(_, items)
                            local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                            local kind_idx = #CompletionItemKind + 1
                            CompletionItemKind[kind_idx] = "Copilot"
                            for _, item in ipairs(items) do
                                item.kind = kind_idx
                            end
                            return items
                        end,
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
                        name = "linear"
                    }
                }
            },
            signature = {
                enabled = true,
                window = { border = 'single' },
            },
            completion = {
                menu = {
                    border = 'single',
                    draw = { treesitter = { 'lsp' } },
                    max_height = 15,
                },
                documentation = { window = { border = 'single' } },
                ghost_text = { enabled = true },
                trigger = {
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
