local lspconfig = require("lspconfig")
local lsp_status = require("lsp-status")

local log_to_message = function(_, data, _)
    for _, d in ipairs(data) do
        print(d)
    end
end

local on_attach = function(client, bufnr)
    -- if client.server_capabilities.documentFormattingProvider then
    -- end
    return lsp_status.on_attach(client, bufnr)
end

-- vim.lsp.set_log_level("debug")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = vim.tbl_extend("keep", capabilities or {}, lsp_status.capabilities)


local null_ls_python_opts = function(name, extra_opts)
    local opts = {
        dynamic_command = function(params)
            local venv = require("utils").get_venvdir(params.root)
            if vim.fn.isdirectory(venv) ~= 0 then
                return venv .. "/bin/" .. name
            else
                return name
            end
        end,
        env = function(params)
            local venv = require("utils").get_venvdir(params.root)
            if vim.fn.isdirectory(venv) ~= 0 then
                local path = venv .. "/bin:" .. vim.fn.getenv("PATH")
                return { VIRTUAL_ENV = venv, PATH = path }
            else
                return {}
            end
        end
    }
    return vim.tbl_deep_extend("force", opts, extra_opts or {})
end

local on_new_config_poetry_binary_install = function(deps, name, cmd, args)
    return function(new_config, new_root_dir)
        local venv = require("utils").get_venvdir(new_root_dir)
        if vim.fn.isdirectory(venv) ~= 0 then
            local venv_bin_path = venv .. "/bin/" .. cmd
            if vim.fn.filereadable(venv_bin_path) == 0 then
                vim.fn.jobstart(
                    venv .. "/bin/pip install " .. deps,
                    {
                        on_stdout = log_to_message,
                        on_stderr = log_to_message,
                        on_exit = function() vim.cmd("LspRestart " .. name) end
                    }
                )
            else
                local path = venv .. "/bin:" .. vim.fn.getenv("PATH")
                if new_config.cmd_env then
                    new_config.cmd_env.VIRTUAL_ENV = venv
                    new_config.cmd_env.PATH = path
                else
                    new_config.cmd_env = { VIRTUAL_ENV = venv, PATH = path }
                end

                new_config.cmd = { venv_bin_path }
                if (args ~= nil) then
                    for _, arg in ipairs(args) do
                        table.insert(new_config.cmd, arg)
                    end
                end
            end
        else
            print("Virtual env detected but the directory is missing")
        end
    end
end

local lsp_options = {
    common = {
        capabilities = capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150
        }
    },
    html = {},
    jsonls = {},
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
    eslint = { root_dir = lspconfig.util.root_pattern("package.json") },
    tsserver = {
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            return on_attach(client, bufnr)
        end
    },
    grammarly = { filetypes = { "gitcommit" } },
    jedi_language_server = {
        on_new_config = on_new_config_poetry_binary_install(
            "jedi-language-server", "jedi_language_server", "jedi-language-server"
        )
    },
    bashls = { filetypes = { "sh", "zsh" } },
}

local null_ls = require("null-ls")
null_ls.setup({
    on_attach = on_attach,
    sources = {
        null_ls.builtins.formatting.black.with(null_ls_python_opts("black", {
            extra_args = { "--fast" }
        })),
        null_ls.builtins.formatting.isort.with(null_ls_python_opts("isort")),
        null_ls.builtins.diagnostics.flake8.with(null_ls_python_opts("flake8", {
            method = null_ls.methods.DIAGNOSTICS_ON_SAVE
        })),
        null_ls.builtins.diagnostics.mypy.with(null_ls_python_opts("mypy", {
            method = null_ls.methods.DIAGNOSTICS_ON_SAVE
        })),
        null_ls.builtins.diagnostics.yamllint.with(null_ls_python_opts("yamllint")),
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.diagnostics.commitlint,
        null_ls.builtins.diagnostics.vulture.with({ extra_args = { "--min-confidence=70" } }),
    },
})

local servers = {
    "eslint",
    "jedi_language_server",
    "tsserver",
    "lua_ls",
    "grammarly",
    "yamlls"
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    if (lsp_status.extensions[lsp] ~= nil) then
        local handlers = lsp_status.extensions[lsp].setup()
        options.handlers = handlers
    end
    lspconfig[lsp].setup(options)
end
