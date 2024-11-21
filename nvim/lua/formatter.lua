---@diagnostic disable: empty-block
M = {}

M.may_format = function()
    if vim.b.formatter_enabled then
        local can_format = false
        for _, client in ipairs(vim.lsp.get_clients()) do
            if client.name == "eslint" then
                vim.cmd("EslintFixAll")
            end
            can_format = can_format or client.server_capabilities.documentFormattingProvider
        end

        -- M.vim_lsp_buf_code_action_sync({
        --     ruff = {
        --         "source.organizeImports.ruff",
        --         "source.fixAll.ruff",
        --     },
        -- })

        if can_format then
            vim.lsp.buf.format()
        end
    end
end

M.enabled = function()
    return vim.b.formatter_enabled
end

M.on_attach = function(client, bufnr)
    if client.config.root_dir == nil then
        return
    end
    for _, path in ipairs(require("utils").enhanced_experience_paths) do
        local i, _ = string.find(client.config.root_dir, path)
        if i == 1 then
            vim.api.nvim_buf_set_var(bufnr, "formatter_enabled", true)
        end
    end
end

M.toggle = function()
    vim.b.formatter_enabled = not vim.b.formatter_enabled
end

return M
