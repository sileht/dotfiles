local lspconfig = require("lspconfig")
local lsp_status = require("lsp-status")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- vim.lsp.set_log_level("debug")



local lsp_options = {
    common = {
        capabilities = vim.tbl_extend("keep",
            cmp_nvim_lsp.default_capabilities(),
            lsp_status.capabilities
        ),
        on_attach = function(client, bufnr)
            if client.name == "tsserver" then
                -- eslint is used instead
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end
            if client.server_capabilities.documentFormattingProvider then
                require("formatter").on_attach(client, bufnr)
            end
            lsp_status.on_attach(client, bufnr)
        end,
        flags = {
            debounce_text_changes = 150
        }
    },
    grammarly = { filetypes = { "gitcommit" } },
    bashls = { filetypes = { "sh", "zsh" } },
    docker_compose_language_service = { filetypes = { "yaml.docker-compose" } },
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
    jedi_language_server = {
        on_new_config = function(new_config, new_root_dir)
            local venv = require("utils").get_venvdir(new_root_dir)
            if venv ~= nil then
                new_config.init_options.workspace.environmentPath = venv .. "/bin/python"
            end
        end,
        init_options = { workspace = {} }
    },
    diagnosticls = {
        on_new_config = function(new_config, new_root_dir)
            local venv = require("utils").get_venvdir(new_root_dir)
            if venv ~= nil then
                new_config.init_options.formatters.black.command = venv .. "/bin/black"
                new_config.init_options.formatters.isort.command = venv .. "/bin/isort"
                new_config.init_options.linters.flake8.command = venv .. "/bin/flake8"
                new_config.init_options.linters.mypy.command = venv .. "/bin/mypy"
                new_config.init_options.linters.pylint.command = venv .. "/bin/pylint"
                new_config.init_options.linters.yamllint.command = venv .. "/bin/yamllint"
            end
        end,
        init_options = {
            formatFiletypes = { python = { "black", "isort" } },
            formatters = {
                black = { command = "black", args = { "--fast", "-q", "-" } },
                isort = { command = "isort", args = { "-q", "-" } }
            },
            filetypes = { python = { "flake8", "mypy" }, yaml = { "yamllint" } },
            linters = {
                yamllint = {
                    debounce = 10,
                    sourceName = 'yamllint',
                    command = "yamllint",
                    rootPatterns = { ".git" },
                    args = { "-f", "parsable", '%filepath' },
                    formatPattern = {
                        [[^.*:(\d+):(\d+): \[(\w+)\] (.*)$]],
                        { line = 1, column = 2, security = 3, message = { '[yamllint] ', 4 } }
                    },
                    securities = {
                        warning = 'warning',
                        error = 'error'
                    }
                },
                mypy = {
                    debounce = 1000,
                    sourceName = "mypy",
                    command = "mypy",
                    rootPatterns = { ".git", "pyproject.toml", "setup.py" },
                    args = {
                        '--show-error-codes',
                        '--hide-error-context',
                        "--show-column-numbers",
                        "--no-color-output",
                        "--no-error-summary",
                        '--no-pretty',
                        "%file"
                    },
                    formatPattern = {
                        "^.*:(\\d+?):(\\d+?): ([a-zA-Z]+?): (.*)$",
                        { line = 1, column = 2, security = 3, message = 4 },
                    },
                    securities = { error = "error", warning = "warning", note = "hint" },
                },
                flake8 = {
                    sourceName = "flake8",
                    rootPatterns = { ".git", "pyproject.toml", "setup.py" },
                    command = "flake8",
                    args = {
                        "--format=%(row)d,%(col)d,%(code).1s,%(code)s: %(text)s",
                        "-"
                    },
                    offsetLine = 0,
                    offsetColumn = 0,
                    formatLines = 1,
                    formatPattern = {
                        "(\\d+),(\\d+),([A-Z]),(.*)(\\r|\\n)*$",
                        { line = 1, column = 2, security = 3, message = 4 }
                    },
                    securities = { W = "info", E = "warning", F = "info", C = "info", N = "hint" },
                },
                pylint = {
                    debounce = 1000,
                    sourceName = "pylint",
                    command = "pylint",
                    args = {
                        "--output-format", "text",
                        "--score", "no",
                        "-E",
                        "--msg-template", "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
                        "%file"
                    },
                    formatPattern = {
                        "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
                        {
                            line = 1,
                            column = 2,
                            security = 3,
                            message = 4
                        }
                    },
                    rootPatterns = { ".git", "pyproject.toml", "setup.py" },
                    securities = {
                        informational = "hint",
                        refactor = "info",
                        convention = "info",
                        warning = "warning",
                        error = "error",
                        fatal = "error"
                    },
                    offsetColumn = 1,
                    formatLines = 1
                }
            },
        }
    },
}

local servers = {
    "eslint",
    "jedi_language_server",
    "tsserver",
    "lua_ls",
    "grammarly",
    "diagnosticls",
    "vimls",
    "dockerls",
    "docker_compose_language_service",
    "marksman",
    "html",
    "cssls",
    "jsonls",
    "yamlls",
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    if (lsp_status.extensions[lsp] ~= nil) then
        options.handlers = lsp_status.extensions[lsp].setup()
    end
    lspconfig[lsp].setup(options)
end
