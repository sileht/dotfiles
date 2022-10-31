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

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- html: Enable (broadcasting) snippet capability for completion
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = vim.tbl_extend("keep", capabilities or {}, lsp_status.capabilities)

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
          globals = {"vim"}
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
  --grammarly = {
  --    filetypes = { "markdown", "gitcommit", "rst" }
  --},
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
  },
  semgrep = {}
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
lspconfig_configs["semgrep"] = {
  default_config = {
    cmd = {"semgrep", "lsp", "-l", "/Users/sileht/semgrep.log", "--debug", "--verbose"},
    filetypes = {"python"},
    root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile"),
    single_file_support = true
  }
}

local servers = {
  -- "vimls",
  "eslint",
  "bashls",
  -- 'stylelint_lsp',
  "yamlls",
  "jedi_language_server",
  -- "html",
  -- 'jsonls',
  -- "taplo",
  -- "semgrep",
  "tsserver",
  -- "sumneko_lua",
  -- "grammarly"
  --'dmypy_ls',
  --"flake8_ls"
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
