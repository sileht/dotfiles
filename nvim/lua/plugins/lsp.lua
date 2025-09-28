-- vim.lsp.set_log_level("error")


local ENABLED_LSP_SERVERS = {
    "ruff",
    "jedi_language_server",
    "biome",
    "eslint",
    "ts_ls",

    "html",
    "cssls",
    "bashls",
    "harper_ls",

    "lua_ls",
    "vimls",
    "dockerls",
    "docker_compose_language_service",
    "marksman",
    --"jsonls",
    --"grammarly",
    "terraformls",
    --"copilot",
}


local LSP_SERVERS_OPTIONS = {
    ruff = {
        settings = {
            configuration = {
                lint = {
                    ["unsafe-fixes"] = true
                }
            }
        }
    },
    biome = {
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
        end,
    },
    eslint = {
        on_attach = function(client, bufnr)
            -- biome is used instead
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
            format = false,
        },
    },
    ts_ls = {
        on_attach = function(client, bufnr)
            -- biome is used instead
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            },
        },
    },
    grammarly = { filetypes = { "gitcommit" } },
    bashls = { filetypes = { "sh", "zsh" } },
    docker_compose_language_service = { filetypes = { "yaml.docker-compose" } },
    ['harper_ls'] = {},
    lua_ls = {
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if
                    path ~= vim.fn.stdpath('config')
                    and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
                then
                    return
                end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                    version = 'LuaJIT',
                    path = {
                        'lua/?.lua',
                        'lua/?/init.lua',
                    },
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME
                    }
                }
            })
        end,
        settings = {
            Lua = {
                format = {
                    enable = true,
                    defaultConfig = {
                        indent_style = "space",
                        indent_size = "2",
                    }
                },
                diagnostics = {
                    --globals = { "vim" },
                    severity = {
                        ["action-after-return"] = "Info",
                        ["undefined-global"] = "Ignore",
                    },
                },
                telemetry = { enable = false }
            }
        }
    },
    jedi_language_server = {
        init_options = {
            --hover = { enable = false },
            diagnostics = { enable = true },
            jediSettings = { debug = false },
            completion = {
                disableSnippets = true,
                resolveEagerly = true,
            },
            --semanticTokens = { enable = true },
        },
        before_init = function(init_params, config)
            local venv = require("utils").get_venvdir(config.root_dir)
            if venv ~= nil then
                init_params.initializationOptions.workspace = { environmentPath = venv .. "/bin/python" }
            end
        end,
    },
    ty = {
        before_init = function(init_params, config)
            local venv = require("utils").get_venvdir(config.root_dir)
            if venv ~= nil then
                init_params.initializationOptions.workspace = { environmentPath = venv .. "/bin/python" }
            end
        end,
    },
    copilot = {
        cmd = { 'copilot-language-server', '--stdio' },
        root_markers = { '.git' },
        init_options = {
            copilotIntegrationId = "vscode-chat",
        },
    },
}


local function config()
    local null_ls = require("null-ls")
    null_ls.setup({
        -- on_attach = function(client, bufnr)
        --     client.server_capabilities.documentFormattingProvider = false
        --     client.server_capabilities.documentRangeFormattingProvider = false
        -- end,
        sources = {
            null_ls.builtins.code_actions.gitrebase.with({}),
            null_ls.builtins.formatting.sqlfluff.with({
                method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
            }),
            null_ls.builtins.diagnostics.sqlfluff.with({
                method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
            }),
            null_ls.builtins.diagnostics.mypy.with({
                only_local = ".venv/bin",
                method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                debounce = 250,
                timeout = 20000,
                runtime_condition = function(params)
                    return vim.fn.filereadable(params.bufname) == 1
                end
            }),
            null_ls.builtins.diagnostics.yamllint.with({
                only_local = ".venv/bin",
            }),
            null_ls.builtins.diagnostics.actionlint.with({
                runtime_condition = function(params)
                    return params.lsp_params.textDocument.uri:match(".github/workflow") ~= nil
                end,
            }),
        },
        debug = true
    })

    vim.lsp.config('*', { flags = { debounce_text_changes = 150 } })
    vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

    for _, lsp in ipairs(ENABLED_LSP_SERVERS) do
        if LSP_SERVERS_OPTIONS[lsp] ~= nil then
            vim.lsp.config(lsp, LSP_SERVERS_OPTIONS[lsp])
        end
        vim.lsp.enable(lsp)
    end
end

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "Saghen/blink.cmp",
        {
            "nvimtools/none-ls.nvim",
            dependencies = {
                "nvimtools/none-ls-extras.nvim",
                'MunifTanjim/prettier.nvim',
            },
        },
    },
    config = config
}
