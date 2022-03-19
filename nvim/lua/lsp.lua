local on_attach = function(client, _)
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.resolved_capabilities.document_formatting then
    vim.cmd(
      [[
    augroup LspFormatting
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
    augroup END
    ]]
    )
  end
end

local log_to_message = function(_, data, _)
  for _, d in ipairs(data) do
    print(d)
  end
end

local lspconfig = require("lspconfig")
local lspconfig_configs = require("lspconfig.configs")

local cmp_capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
cmp_capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_new_config_tox_binary_install = function(name, args)
  return function(new_config, new_root_dir)
    local venv = new_root_dir .. "/.tox/pep8"
    if vim.fn.isdirectory(venv) ~= 0 then
      local venv_bin_path = venv .. "/bin/" .. name
      if vim.fn.filereadable(venv_bin_path) == 0 then
        vim.fn.jobstart(
          venv .. "/bin/pip install " .. name,
          {
            on_stdout = log_to_message,
            on_stderr = log_to_message,
            on_exit = function()
              vim.fn.jobstart(
                venv .. "/bin/pip install -U pydantic",
                {
                  on_stdout = log_to_message,
                  on_stderr = log_to_message,
                  on_exit = function()
                    vim.api.nvim_command("LspRestart")
                  end
                }
              )
            end
          }
        )
      else
        new_config.cmd = {venv_bin_path}
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
      debounce_text_changes = 150
    }
  },
  html = {},
  jsonls = {},
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = {
          globals = {"vim"}
        },
        telemetry = {
          enable = false
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
  tsserver = {
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
      return on_attach(client, bufnr)
    end
  },
  grammarly = {
    filetypes = {"markdown", "gitcommit", "rst"}
  },
  --
  flake8_ls = {
    on_new_config = on_new_config_tox_binary_install("flake8-ls")
  },
  dmypy_ls = {
    on_new_config = function(new_config, new_root_dir)
      return on_new_config_tox_binary_install("dmypy-ls", {"--chdir=" .. new_root_dir})(new_config, new_root_dir)
    end
  },
  jedi_language_server = {
    on_new_config = on_new_config_tox_binary_install("jedi-language-server")
  },
  bashls = {
    filetypes = {"sh", "zsh"}
  }
}

lspconfig_configs["flake8_ls"] = {
  default_config = {
    cmd = {"flake8-ls"},
    filetypes = {"python"},
    root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile"),
    single_file_support = true
  }
}
lspconfig_configs["dmypy_ls"] = {
  default_config = {
    cmd = {"dmypy-ls"},
    filetypes = {"python"},
    root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile"),
    single_file_support = true
  }
}

local servers = {
  "vimls",
  "eslint",
  "bashls",
  -- 'stylelint_lsp',
  "yamlls",
  "jedi_language_server",
  -- "html",
  -- 'jsonls',
  "taplo",
  "yamlls",
  "sumneko_lua",
  "grammarly"
  --'dmypy_ls',
  --"flake8_ls"
  --'tsserver',
}
for _, lsp in ipairs(servers) do
  local options = vim.deepcopy(lsp_options.common)
  if (lsp_options[lsp] ~= nil) then
    options = vim.tbl_extend("force", options, lsp_options[lsp])
  end
  lspconfig[lsp].setup(options)
end
