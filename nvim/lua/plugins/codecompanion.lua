return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        display = {
            chat = { show_settings = true },
            action_palette = { provider = 'telescope' },
        },
        strategies = {
            chat = {
                adapter = "copilot",
            },
            inline = {
                adapter = "copilot",
            },
        },
        adapters = {
            copilot = function()
                return require("codecompanion.adapters").extend("copilot", {
                    schema = {
                        model = {
                            default = "o3-mini",
                            --default = "gpt-4o",
                            --default = "gemini-2.0-flash-001",
                            -- default = "claude-3.7-sonnet-thought",
                            -- default = "claude-3.7-sonnet",
                        }
                    },
                })
            end,
            openai = function()
                return require("codecompanion.adapters").extend("openai", {
                    env = {
                        api_key = "cmd:security find-generic-password -w -s ENV_OPENAI_TOKEN"
                    },
                })
            end,
        },
    }
}
