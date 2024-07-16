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

        M.vim_lsp_buf_code_action_sync({
            ruff_lsp = {
                "source.organizeImports",
                "source.fixAll",
            },
        })

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

M.vim_lsp_buf_code_action_sync = function(config)
    -- sync equivalent of vim.lsp.buf.code_action({
    -- Should be fixed by https://github.com/neovim/neovim/pull/22598
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local ms = require('vim.lsp.protocol').Methods
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = ms.textDocument_codeAction })
    for _, client in ipairs(clients) do
        local actions = config[client.name]
        --print(vim.inspect(client))
        if actions ~= nil then
            for _, action in ipairs(actions) do
                local encoding = client.offset_encoding or "utf-8"
                local params = vim.lsp.util.make_range_params(win, encoding)
                params.context = {
                    only = { action },
                    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr)
                }
                params.apply = true
                local response = client.request_sync(ms.textDocument_codeAction, params, 1000, bufnr)
                if response ~= nil then
                    for _, r in pairs(response.result or {}) do
                        if vim.tbl_contains(actions, r.kind) then
                            if r.edit then
                                vim.lsp.util.apply_workspace_edit(r.edit, encoding)
                            end
                        else
                            print(vim.inspect(client))
                            print(vim.inspect(params))
                            print(vim.inspect(r))
                            print(action)
                        end
                    end
                end
            end
        end
    end
end

return M
