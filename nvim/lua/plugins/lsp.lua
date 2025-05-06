vim.lsp.set_log_level("error")
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
    config = function()
        local lspconfig = require("lspconfig")

        local lsp_options = {
            common = {
                capabilities = require('blink.cmp').get_lsp_capabilities(),
                -- capabilities = cmp_nvim_lsp.default_capabilities(),
                on_attach = function(client, bufnr)
                    if client.name == "ts_ls" then
                        -- biome is used instead
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end
                    if client.name == "null-ls" then
                        -- Bugged
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end
                    if client.name == "eslint" then
                        -- biome is used instead
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end


                    if client.name == "ts_ls" then
                        -- biome is used instead
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end

                    if client.name == "biome" then
                        client.server_capabilities.documentFormattingProvider = true
                        client.server_capabilities.documentRangeFormattingProvider = true
                    end

                    require("formatter").on_attach(client, bufnr)
                end,
                flags = {
                    debounce_text_changes = 150
                }
            },
            ruff = {
                settings = {

                }
            },
            eslint = {
                settings = {
                    format = false,
                },
            },
            ts_ls = {
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
            vtsls = {},
            lua_ls = {
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
                            globals = { "vim" },
                            severity = {
                                ["action-after-return"] = "Info",
                                ["undefined-global"] = "Ignore",
                            },
                        },
                        telemetry = { enable = false }
                    }
                }
            },
            pyright = {
                on_new_config = function(new_config, new_root_dir)
                    local venv = require("utils").get_venvdir(new_root_dir)
                    if venv ~= nil then
                        new_config.settings = {
                            python = {
                                pythonPath = venv .. "/bin/python",
                                venvPath = venv,
                            }
                        }
                    end
                end
            },
            jedi_language_server = {
                on_new_config = function(new_config, new_root_dir)
                    local venv = require("utils").get_venvdir(new_root_dir)
                    if venv ~= nil then
                        new_config.init_options.workspace = { environmentPath = venv .. "/bin/python" }
                        new_config.init_options.hover = { enable = false }
                        new_config.init_options.diagnostics = { enable = true }
                        new_config.init_options.jediSettings = { debug = false }
                    end
                end,
            },
            red_knot = {
                on_new_config = function(new_config, new_root_dir)
                    local venv = require("utils").get_venvdir(new_root_dir)
                    if venv ~= nil then
                        new_config.init_options.workspace = { environmentPath = venv .. "/bin/python" }
                    end
                end,
            },
        }

        local lspconfig = require('lspconfig')
        local configs = require('lspconfig.configs')
        configs.copilot = {
            default_config = {
                cmd = { 'copilot-language-server', '--stdio' },
                root_dir = lspconfig.util.root_pattern('.git'),
                init_options = {
                    copilotIntegrationId = "vscode-chat",
                },
            },
        }

        local null_ls = require("null-ls")
        local null_ls_sources = {
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
        }
        null_ls.setup({ on_attach = lsp_options.common.on_attach, sources = null_ls_sources, debug = true })

        local servers = {
            "ruff",
            "jedi_language_server",
            "biome",
            "eslint",
            "ts_ls",

            "html",
            "cssls",

            "lua_ls",
            "vimls",
            "dockerls",
            "docker_compose_language_service",
            "marksman",
            --"jsonls",
            "grammarly",
            "terraformls",
            --"red_knot",
            --"copilot",
        }

        for _, lsp in ipairs(servers) do
            local options = vim.deepcopy(lsp_options.common)
            if (lsp_options[lsp] ~= nil) then
                options = vim.tbl_extend("force", options, lsp_options[lsp])
            end
            lspconfig[lsp].setup(options)
        end
    end
}
