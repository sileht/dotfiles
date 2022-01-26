
local on_attach = function(client, _)
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  if client.resolved_capabilities.document_formatting then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
end

local log_to_message = function(_, data, _)
  for _, d in ipairs(data) do
    print(d)
  end
end


local null_ls = require('null-ls')
local lspconfig = require('lspconfig')
local lspconfig_configs = require('lspconfig.configs')

local cmp_capabilities = require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
)
-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
cmp_capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_new_config_tox_binary_install = function(name, args)
    return function(new_config, new_root_dir)
        local venv = new_root_dir .. '/.tox/pep8';
        if vim.fn.isdirectory(venv) ~= 0 then
            local venv_bin_path = venv .. '/bin/' .. name;
            if vim.fn.filereadable(venv_bin_path) == 0 then
                vim.fn.jobstart(venv .. '/bin/pip install ' .. name, {
                    on_stdout = log_to_message,
                    on_stderr = log_to_message,
                    on_exit = function()
                        vim.api.nvim_command('LspRestart')
                    end
                })
            else
                new_config.cmd = {venv_bin_path};
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
        capabilities = cmp_capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        },
    },
    html = {
        --capabilities = vscode_lsp_capabilities,
    },
    jsonls = {
        --capabilities = vscode_lsp_capabilities,
    },
    sumneko_lua = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                },
                telemetry = {
                    enable = false,
                },
            }
        }
    },
    eslint = {
        on_attach = function(client, bufnr)
            vim.cmd("autocmd BufWritePre <buffer> :EslintFixAll")
            return on_attach(client, bufnr)
        end
    },
    grammarly = {
        filetypes = { 'markdown', 'gitcommit', 'rst' },
    },
    --[[--
    flake8_ls = {
        on_new_config = on_new_config_tox_binary_install("flake8-ls"),
    },
    dmypy_ls = {
        on_new_config = function(new_config, new_root_dir)
            return on_new_config_tox_binary_install(
                "dmypy-ls", {"--chdir=" .. new_root_dir}
            )(new_config, new_root_dir)
        end
    },
    --]]--
    jedi_language_server = {
        on_new_config = on_new_config_tox_binary_install("jedi-language-server"),
    },
    bashls = {
        filetypes = { 'sh', 'zsh' },
    }
}

lspconfig_configs["flake8_ls"] = {
    default_config = {
        cmd = { 'flake8-ls' },
        filetypes = { 'python' },
        root_dir = lspconfig.util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'),
        single_file_support = true,
    },
}
lspconfig_configs["dmypy_ls"] = {
    default_config = {
        cmd = { 'dmypy-ls' },
        filetypes = { 'python' },
        root_dir = lspconfig.util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'),
        single_file_support = true,
    },
}

local servers = {
    'vimls',
    'eslint',
    'bashls',
--  'stylelint_lsp',
    'yamlls',
    'jedi_language_server',
    'html',
--    'jsonls',
    'taplo',
    'yamlls',
    'sumneko_lua',
    'grammarly',
    --'dmypy_ls',
    --'flake8_ls',
    --'tsserver',
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    lspconfig[lsp].setup(options)
end


require("null-ls").setup({
    debug = true,
    on_attach = on_attach,
    sources = {
        null_ls.builtins.diagnostics.mypy.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.diagnostics.flake8.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.formatting.isort.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.formatting.black.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.stylelint,
        --[[--
        null_ls.builtins.formatting.eslint.with({
            prefer_local = "node_modules/.bin/eslint"
        }),
        null_ls.builtins.diagnostics.eslint.with({
            prefer_local = "node_modules/.bin/eslint"
        }),
        null_ls.builtins.code_actions.eslint.with({
            prefer_local = "node_modules/.bin/eslint"
        }),
        --]]--
        null_ls.builtins.diagnostics.vale,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.shellcheck,


        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.code_actions.gitrebase,

        -- null_ls.builtins.formatting.trim_whitespace,
        -- null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.hover.dictionary,
    },
})
