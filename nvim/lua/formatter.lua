return {
    may_format = function()
        if vim.b.formatter_enabled then
            vim.lsp.buf.format()
        end
    end,
    enabled = function()
        return vim.b.formatter_enabled
    end,
    on_attach = function(client, bufnr)
        if client.config.root_dir == nil then
            return
        end
        for _, path in ipairs(require("utils").enhanced_experience_paths) do
            local i, _ = string.find(client.config.root_dir, path)
            if i == 1 then
                vim.api.nvim_buf_set_var(bufnr, "formatter_enabled", true)
            end
        end
    end,
    toggle = function()
        vim.b.formatter_enabled = not vim.b.formatter_enabled
    end,
}
