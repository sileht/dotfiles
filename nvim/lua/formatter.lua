---@diagnostic disable: empty-block
M = {}

M.enhanced_experience_paths = {
    "/Users/sileht/workspace/mergify/engine",
    "/Users/sileht/workspace/mergify/infra",
    "/Users/sileht/workspace/mergify/infrastructure",
    "/Users/sileht/workspace/mergify/shadow_office",
    "/Users/sileht/workspace/mergify/cotyledon",
    "/Users/sileht/workspace/mergify/ui",
    "/Users/sileht/workspace/mergify/pytest-mergify",
    "/Users/sileht/workspace/mergify/docs",
    "/Users/sileht/workspace/mergify/gha-ci-issues",
    "/Users/sileht/workspace/mergify/cli",
    "/Users/sileht/workspace/mergify/heroku",
    "/Users/sileht/workspace/mergify/events-forwarder",
    "/Users/sileht/.env",
    "/Users/sileht/.config",
}

M.enabled_on_current_buffer = function()
    return vim.b.formatter_enabled
end

M.enabled_on_buffer = function(bufnr)
    return vim.b[bufnr].formatter_enabled
end


M.toggle = function()
    vim.b.formatter_enabled = not vim.b.formatter_enabled
end

M.setup = function()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        callback = function(args)
            for _, path in ipairs(M.enhanced_experience_paths) do
                local found = vim.startswith(args.match, path)
                if found then
                    vim.api.nvim_buf_set_var(args.buf, "formatter_enabled", true)
                end
            end
        end
    })
end

return M
