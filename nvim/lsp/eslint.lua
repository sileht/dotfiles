return {
    on_attach = function(client, bufnr)
        -- biome is used instead
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
    settings = {
        format = false,
    },
}
