local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- vim.lsp.set_log_level("info")

local lsp_options = {
    common = {
        capabilities = cmp_nvim_lsp.default_capabilities(),
        on_attach = function(client, bufnr)
            if client.name == "ruff_lsp" then
                -- client.server_capabilities.documentFormattingProvider = false
                -- client.server_capabilities.documentRangeFormattingProvider = false
            end
            if client.name == "tsserver" then
                -- eslint is used instead
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end
            require("formatter").on_attach(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                require("nvim-navic").attach(client, bufnr)
            end
        end,
        flags = {
            debounce_text_changes = 150
        }
    },
    ruff_lsp = {
        init_options = {
            settings = {
                args = {},
            }
        }
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
            end
        end,
    },
}

require("lspconfig.configs")["dmypyls"] = {
    default_config = {
        cmd = { 'dmypy-ls' },
        filetypes = { 'python' },
        root_dir = lspconfig.util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'),
        single_file_support = true,
    },
}

local null_ls = require("null-ls")
local null_ls_sources = {
    null_ls.builtins.formatting.prettier.with({
        runtime_condition = function(params)
            return require("null-ls.utils").root_pattern(".prettierrc.json")(params.bufname) ~= nil
        end,
    }),
    null_ls.builtins.formatting.black.with({ only_local = ".venv/bin", extra_args = { "--fast" } }),
    require("none-ls.formatting.ruff").with({
        only_local = ".venv/bin",
        extra_args = { "--ignore", "F841,F401" }
    }),
    null_ls.builtins.formatting.isort.with({ only_local = ".venv/bin" }),
    require("none-ls.diagnostics.flake8").with({
        only_local = ".venv/bin",
        condition = function(utils)
            return utils.root_has_file({ ".flake8" })
        end,
        -- method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    }),
    null_ls.builtins.diagnostics.mypy.with({
        only_local = ".venv/bin",
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
        debounce = 250,
        timeout = 20000,
    }),
    null_ls.builtins.diagnostics.yamllint.with({
        only_local = ".venv/bin",
    }),
    null_ls.builtins.diagnostics.actionlint.with({
        runtime_condition = function(params)
            return params.lsp_params.textDocument.uri:match(".github/workflow") ~= nil
        end,
    }),
    require("prettier").setup({
        ["null-ls"] = {
            condition = function()
                return require("prettier").config_exists({
                    -- if `false`, skips checking `package.json` for `"prettier"` key
                    check_package_json = true,
                })
            end,
            timeout = 5000,
        }
    })
}
null_ls.setup({ on_attach = lsp_options.common.on_attach, sources = null_ls_sources })

local servers = {
    "ruff_lsp",
    "jedi_language_server",
    "eslint",
    "tsserver",

    "html",
    "cssls",

    "lua_ls",
    "vimls",
    "dockerls",
    "docker_compose_language_service",
    "marksman",
    "jsonls",
    "grammarly",
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    lspconfig[lsp].setup(options)
end
