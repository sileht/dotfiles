
local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
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
local coq = require('coq')

-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
local vscode_lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
vscode_lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

local lsp_options = {
    common = {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        },
    },
    html = {
        capabilities = vscode_lsp_capabilities,
    },
    jsonls = {
        capabilities = vscode_lsp_capabilities,
    },
    sumneko_lua = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                }
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
    dmypy_ls = {
        on_new_config = function(new_config, new_root_dir)
            local venv = new_root_dir .. '/.tox/pep8';
            if vim.fn.isdirectory(venv) ~= 0 then
                local venv_dmypy_bin = venv .. '/bin/dmypy-ls';
                if vim.fn.filereadable(venv_dmypy_bin) == 0 then
                    vim.fn.jobstart(venv .. '/bin/pip install dmypy-ls', {
                        on_stdout = log_to_message,
                        on_stderr = log_to_message,
                        on_exit = function()
                            for _, client in ipairs(vim.lsp.get_active_clients()) do
                                if (client.name == "dmypy_ls") then
                                    client.stop()
                                end
                            end
                            lspconfig_configs.dmypy_ls.launch()
                            --vim.api.nvim_command('LspStop python')
                            --vim.api.nvim_command('LspRestart python')
                        end
                    })
                else
                    new_config.cmd = {venv_dmypy_bin};
                end
            end
        end
    },
    jedi_language_server = {
        on_new_config = function(new_config, new_root_dir)
            local venv = new_root_dir .. '/.tox/pep8';
            if vim.fn.isdirectory(venv) ~= 0 then
                local venv_jedi_bin = venv .. '/bin/jedi-language-server';
                if vim.fn.filereadable(venv_jedi_bin) == 0 then
                    vim.fn.jobstart(venv .. '/bin/pip install jedi-language-server', {
                        on_stdout = log_to_message,
                        on_stderr = log_to_message,
                        on_exit = function()
                            for _, client in ipairs(vim.lsp.get_active_clients()) do
                                if (client.name == "jedi_language_server") then
                                    client.stop()
                                end
                            end
                            lspconfig_configs.jedi_language_server.launch()
                            --vim.api.nvim_command('LspStop python')
                            --vim.api.nvim_command('LspRestart python')
                        end
                    })
                else
                    new_config.cmd = {venv_jedi_bin};
                end
            end
            return new_config;
        end
    }
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
    'jsonls',
    'taplo',
    'yamlls',
    'sumneko_lua',
    'grammarly',
    'dmypy_ls',
}
for _, lsp in ipairs(servers) do
    local options = vim.deepcopy(lsp_options.common)
    if (lsp_options[lsp] ~= nil) then
        options = vim.tbl_extend("force", options, lsp_options[lsp])
    end
    lspconfig[lsp].setup(coq.lsp_ensure_capabilities(options))
end


require("null-ls").setup({
    debug = false,
    on_attach = on_attach,
    sources = {
        null_ls.builtins.formatting.isort.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.formatting.black.with({
            prefer_local = ".tox/pep8/bin",
        }),
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.stylelint,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.vale,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.shellcheck,

        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.code_actions.gitrebase,

        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.hover.dictionary,
    },
})
