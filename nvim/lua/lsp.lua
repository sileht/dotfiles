local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- vim.lsp.set_log_level("info")

local log_to_message = function(_, data, _)
    for _, d in ipairs(data) do
        print(d)
    end
end

---@diagnostic disable-next-line: unused-function,unused-local
local on_new_config_venv_binary_install = function(name, args)
    return function(new_config, new_root_dir)
        local venv = require("utils").get_venvdir(new_root_dir)
        if vim.fn.isdirectory(venv) ~= 0 then
            local venv_bin_path = venv .. "/bin/" .. name
            if vim.fn.filereadable(venv_bin_path) == 0 then
                vim.fn.jobstart(
                    venv .. "/bin/pip install " .. name,
                    {
                        on_stdout = log_to_message,
                        on_stderr = log_to_message,
                        on_exit = function()
                            vim.api.nvim_command("LspRestart")
                        end
                    }
                )
            else
                new_config.cmd = { venv_bin_path }
                if (args ~= nil) then
                    for _, arg in ipairs(args) do
                        table.insert(new_config.cmd, arg)
                    end
                end
            end
        end
    end
end

local lsp_options = {
    common = {
        capabilities = cmp_nvim_lsp.default_capabilities(),
        on_attach = function(client, bufnr)
            if client.name == "ruff_lsp" then
                client.server_capabilities.hoverProvider = false

                -- Not ready yet
                -- client.server_capabilities.documentFormattingProvider = false
                -- client.server_capabilities.documentRangeFormattingProvider = false
            end
            if client.name == "tsserver" then
                -- eslint is used instead
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end
            if client.server_capabilities.codeLensProvider then
                require('virtualtypes').on_attach(client, bufnr)
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
    dmypyls = {
        on_new_config = function(new_config, new_root_dir)
            --on_new_config_venv_binary_install("dmypy-ls", { "--chdir=" .. new_root_dir })(new_config, new_root_dir)
            local venv = require("utils").get_venvdir(new_root_dir)
            if venv ~= nil then
                --[[ new_config.cmd = { "dmypy-ls", "--chdir=" .. new_root_dir, "--virtualenv=" .. venv } ]]
                new_config.cmd = { venv .. "/bin/dmypy-ls", "--chdir=" .. new_root_dir }
            end
        end
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
    null_ls.builtins.formatting.ruff.with({
        only_local = ".venv/bin",
        extra_args = { "--ignore", "F841,F401" }
    }),
    null_ls.builtins.formatting.isort.with({ only_local = ".venv/bin" }),
    null_ls.builtins.diagnostics.flake8.with({
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
    --null_ls.builtins.diagnostics.commitlint,
    --null_ls.builtins.diagnostics.vulture.with({ extra_args = { "--min-confidence=70" } }),
}
null_ls.setup({ on_attach = lsp_options.common.on_attach, sources = null_ls_sources })

local servers = {
    --"pyright",
    "ruff_lsp",
    "jedi_language_server",
    "eslint",
    "tsserver",
    --"vtsls",

    "html",
    "cssls",

    "lua_ls",
    "vimls",
    "dockerls",
    "docker_compose_language_service",
    "marksman",
    "jsonls",
    "grammarly",
    --"dmypyls",
    --"yamlls",
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    lspconfig[lsp].setup(options)
end
