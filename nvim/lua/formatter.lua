---@diagnostic disable: empty-block
M = {}

local function _vim_lsp_buf_code_action_sync(action, buf, timeout_ms, attempts)
    if attempts > 3 then
        vim.notify("Max resolve attempts reached for action " .. action.kind, vim.log.levels.WARN)
        return
    end

    if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
    elseif action.command then
        vim.lsp.buf.execute_command(action.command)
    else
        -- neovim:runtime/lua/vim/lsp/buf.lua shows how to run a code action
        -- synchronously. This section is based on that.
        local resolve_result = vim.lsp.buf_request_sync(buf, "codeAction/resolve", action, timeout_ms)
        if resolve_result then
            for _, resolved_action in pairs(resolve_result) do
                _vim_lsp_buf_code_action_sync(resolved_action.result, buf, timeout_ms, attempts + 1)
            end
        else
            vim.notify("Failed to resolve code action " .. action.kind .. " without edit or command", vim.log.levels
                .WARN)
        end
    end
end

local function vim_lsp_buf_code_action_sync(kinds)
    local timeout_ms = 100
    local buf = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_range_params(0, "utf-8")
    params.context = { diagnostics = {} }

    local results = vim.lsp.buf_request_sync(buf, "textDocument/codeAction", params, timeout_ms)
    if not results then
        return
    end

    for _, result in pairs(results) do
        for _, action in pairs(result.result or {}) do
            for _, kind in pairs(kinds) do
                if action.kind == kind then
                    _vim_lsp_buf_code_action_sync(action, buf, timeout_ms, 0)
                end
            end
        end
    end
end



M.may_format = function()
    if vim.b.formatter_enabled then
        local can_format = false

        local code_actions = {
            ruff = {
                "source.organizeImports.ruff",
                "source.fixAll.ruff",
            },
            eslint = {
                "source.fixAll",
            },
            biome = {
                "source.organizeImports.biome",
            },
        }

        local kinds = {}
        for _, client in ipairs(vim.lsp.get_clients()) do
            if code_actions[client.name] ~= nil then
                vim.list_extend(kinds, code_actions[client.name])
            end
            if client.name == "eslint" then
                vim.cmd("EslintFixAll")
            end
            --print(client.name)
            --print(vim.inspect(client.server_capabilities.documentFormattingProvider))
            can_format = can_format or client.server_capabilities.documentFormattingProvider
        end

        --print(vim.inspect(kinds))
        if next(kinds) ~= nil then
            vim_lsp_buf_code_action_sync(kinds)
            vim_lsp_buf_code_action_sync(kinds)
        end

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
