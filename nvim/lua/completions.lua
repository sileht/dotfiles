local cmp = require("cmp")

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local cursor = vim.api.nvim_win_get_cursor(0)
    if cursor ~= nil then
        local line, col = cursor[1], cursor[2]
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
    end
    return false
end

require("linear_cmp_source").setup()
require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
        javascript = true,
        typescript = true,
        python = true,
        ["*"] = false,
    },
})
require("copilot_cmp").setup()
local lspkind = require('lspkind')
cmp.setup({
    experimental = {
        ghost_text = false,
    },
    sources = cmp.config.sources({
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "buffer" },
        { name = "path" },
    }),
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol",
            max_width = 80,
            symbol_map = { Copilot = "" }
        })
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        --            ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ["<CR>"] = cmp.mapping.confirm({
            -- this is the important line
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end),
    }),
    sorting = {
        priority_weight = 2,
        comparators = {
            require("copilot_cmp.comparators").prioritize,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            require("cmp-under-comparator").under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})
cmp.setup.filetype(
    "gitcommit",
    {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
            {
                { name = "buffer" },
            },
            {
                { name = "linear" },
            }
        )
    }
)
cmp.setup.cmdline(
    { "/", "?" },
    {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } }
    }
)
cmp.setup.cmdline(
    ":",
    {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
    }
)
