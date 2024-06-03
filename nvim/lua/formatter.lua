M = {}

M.code_action_sync = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
    for cid, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-8"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
        end
    end
end

M.may_format = function()
    if vim.b.formatter_enabled then
        local can_format = false
        for _, client in ipairs(vim.lsp.get_clients()) do
            if client.name == "eslint" then
                vim.cmd("EslintFixAll")
            end
            can_format = can_format or client.server_capabilities.documentFormattingProvider
        end
        --[[
        vim.lsp.buf.code_action({
            apply = true,
            filter = function(action)
                return action.title == 'Ruff: Organize Imports'
            end,
        })
        vim.lsp.buf.code_action({
            apply = true,
            filter = function(action)
                return action.title == "Ruff: Fix All"
            end,
        })
        ]]
        --

        if can_format then
            vim.lsp.buf.format()
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
