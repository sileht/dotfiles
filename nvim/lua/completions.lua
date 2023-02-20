local cmp = require("cmp")
cmp.setup(
    {
        snippet = {},
        sources = cmp.config.sources(
            {
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "nvim_lsp_document_symbol" },
                { name = "buffer" },
                { name = "path" },
            }
        ),
        formatting = {
            format = require("lspkind").cmp_format(
                {
                    with_text = true, -- do not show text alongside icons
                    maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                    -- The function below will be called before any actual modifications from lspkind
                    -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                    before = function(entry, vim_item)
                        if entry.source.name == "cmp_tabnine" then
                            local detail = (entry.completion_item.data or {}).detail
                            vim_item.kind = " Tabnine"
                            if detail and detail:find('.*%%.*') then
                                vim_item.kind = vim_item.kind .. ' ' .. detail
                            end

                            if (entry.completion_item.data or {}).multiline then
                                vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
                            end
                        end
                        return vim_item
                    end
                }
            )
        },
        mapping = cmp.mapping.preset.insert(
            {
                ["<C-b>"] = cmp.mapping.scroll_docs( -4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm {
                    --behavior = cmp.ConfirmBehavior.Replace,
                    select = true
                },
                ["<Tab>"] = cmp.mapping(
                    function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end,
                    { "i", "s" }
                ),
                ["<S-Tab>"] = cmp.mapping(
                    function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end,
                    { "i", "s" }
                )
            }
        )
    }
)
cmp.setup.filetype(
    "gitcommit",
    {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
            {
                { name = "cmp_git" },
                { name = "conventionalcommits" },
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
require("cmp_git").setup()
