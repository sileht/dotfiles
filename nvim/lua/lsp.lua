local lspconfig = require("lspconfig")
local lsp_status = require("lsp-status")
local lspconfig_configs = require("lspconfig.configs")

local log_to_message = function(_, data, _)
    for _, d in ipairs(data) do
        print(d)
    end
end

local on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.cmd(
            [[
    augroup LspFormatting
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
    augroup END
    ]]
        )
    end
    return lsp_status.on_attach(client, bufnr)
end

-- vim.lsp.set_log_level("debug")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = vim.tbl_extend("keep", capabilities or {}, lsp_status.capabilities)

local on_new_config_set_virtualenv = function()
    return function(new_config, new_root_dir)
        --local handle = io.popen("poetry env info -p")
        local handle = io.popen("~/.bin/poetry-env-info-fast " .. new_root_dir)
        local venv = handle:read()
        handle:close()
        if vim.fn.isdirectory(venv) ~= 0 then
            if new_config.cmd_env then
                new_config.cmd_env.VIRTUAL_ENV = venv
            else
                new_config.cmd_env = { VIRTUAL_ENV = venv }
            end
            print("VENV SET")
        end
    end
end
local on_new_config_poetry_binary_install = function(name, args)
    return function(new_config, new_root_dir)
        local venv = require("utils").get_venvdir(new_root_dir)
        if venv ~= nil then
            local venv_bin_path = venv .. "/bin/" .. name
            if vim.fn.filereadable(venv_bin_path) == 0 then
                vim.fn.jobstart(
                    venv .. "/bin/pip install " .. name,
                    {
                        on_stdout = log_to_message,
                        on_stderr = log_to_message
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
        capabilities = capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150
        }
    },
    html = {},
    jsonls = {},
    sumneko_lua = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" }
                },
                telemetry = {
                    enable = false
                }
            }
        }
    },
    eslint = {
        root_dir = lspconfig.util.root_pattern("package.json")
    },
    tsserver = {
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            return on_attach(client, bufnr)
        end
    },
    grammarly = {
        filetypes = { "gitcommit" }
    },
    jedi_language_server = {
        on_new_config = on_new_config_poetry_binary_install("jedi-language-server")
        --on_new_config = on_new_config_set_virtualenv()
    },
    bashls = {
        filetypes = { "sh", "zsh" }
    },
    semgrep = {}
}

lspconfig_configs["semgrep"] = {
    default_config = {
        cmd = { "semgrep", "lsp", "-l", "/Users/sileht/semgrep.log", "--debug", "--verbose" },
        filetypes = { "python" },
        root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile"),
        single_file_support = true
    }
}

local servers = {
    "eslint",
    "jedi_language_server",
    -- "semgrep",
    "tsserver",
    -- "sumneko_lua",
    "grammarly",
    "yamlls"
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    if (lsp_status.extensions[lsp] ~= nil) then
        handlers = lsp_status.extensions[lsp].setup()
        options.handlers = handlers
    end
    lspconfig[lsp].setup(options)
end
