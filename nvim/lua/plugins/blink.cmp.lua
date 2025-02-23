-- completions on steroid
--
return {
    "Saghen/blink.cmp",
    version = '*',
    dependencies = {
        "moyiz/blink-emoji.nvim",
        {
            "fang2hou/blink-copilot",
            dependencies = {
                "zbirenbaum/copilot.lua",
                cmd = "Copilot",
                build = ":Copilot auth",
                event = "InsertEnter",
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                    filetypes = {
                        markdown = true,
                        help = true,
                    },
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
            cmdline = {
                enabled = false,
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
                        module = "blink-copilot",
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
