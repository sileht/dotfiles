local cmp = require("cmp")

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

cmp.setup({
    experimental = {
        ghost_text = true,
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    sources = cmp.config.sources({
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lsp_document_symbol" },
        { name = "buffer" },
        { name = "path" },
    }),
    formatting = {
        label = require("copilot_cmp.format").format_label_text,
        insert_text = require("copilot_cmp.format").format_insert_text,
        preview = require("copilot_cmp.format").deindent,
        format = require("lspkind").cmp_format({
            with_text = true, -- do not show text alongside icons
            maxwidth = 50,    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
                local kind_map = {
                    cmp_copilot = " Copilot",
                }
                if kind_map[entry.source.name] ~= nil then
                    local detail = (entry.completion_item.data or {}).detail
                    vim_item.kind = kind_map[entry.source.name]
                    if detail and detail:find('.*%%.*') then
                        vim_item.kind = vim_item.kind .. ' ' .. detail
                    end

                    if (entry.completion_item.data or {}).multiline then
                        vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
                    end
                end
                return vim_item
            end
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
                { name = "cmp_git" },
            },
            {
                { name = "buffer" },
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
require("cmp_git").setup()
