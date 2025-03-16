return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
        --model = "copilot-codex",
        model = "gpt-4o-copilot",
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
            markdown = true,
            help = true,
        },
        copilot_language_server_cmd = { "copilot-language-server", "--stdio" },
        server_opts_overrides = {
            init_options = {
                copilotIntegrationId = "vscode-chat",
            },
        },
    },
}
--[[
return {
  "github/copilot.vim",
    event = "BufWinEnter",
  cmd = "Copilot",
  init = function()
    vim.g.copilot_no_maps = true
    vim.g.copilot_settings = { selectedCompletionModel = 'o3-mini' }
  end,
  config = function()
    -- Block the normal Copilot suggestions
    vim.api.nvim_create_augroup("github_copilot", { clear = true })
    vim.api.nvim_create_autocmd({ "FileType", "BufUnload", "BufEnter" }, {
      group = "github_copilot",
      callback = function(args)
        vim.fn["copilot#On" .. args.event]()
      end,
    })
  end,
}
]]
