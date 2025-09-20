return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
        --model = "copilot-codex",
        copilot_model = "gpt-4o-copilot",
        suggestion = { enabled = false },
        panel = { enabled = false },
        -- filetypes = {
        --     markdown = true,
        --     help = true,
        -- },
        server = {
            type = "binary",
            custom_server_filepath = "copilot-language-server"
        },
        -- copilot_language_server_cmd = { "copilot-language-server", "--stdio" },
        -- server_opts_overrides = {
        --     init_options = {
        --         copilotIntegrationId = "vscode-chat",
        --     },
        -- },
    },
}
