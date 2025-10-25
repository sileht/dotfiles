-- vim.lsp.set_log_level("error")
local ENABLED_LSP_SERVERS = {
    "bashls",
    "biome",
    "cssls",
    "docker_compose_language_service",
    "dockerls",
    "eslint",
    "harper_ls",
    "html",
    --"jedi_language_server",
    "lua_ls",
    "marksman",
    "pyrefly",
    --"ty",
    "ruff",
    "terraformls",
    "ts_ls",
    "vimls",
}
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "Saghen/blink.cmp",
    },
    config = function()
        vim.lsp.config('*', { flags = { debounce_text_changes = 150 } })
        vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
        vim.iter(ENABLED_LSP_SERVERS):map(vim.lsp.enable)
    end
}
