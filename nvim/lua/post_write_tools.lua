M = {}

local get_local_env_path = function()
  local rootdir = require("utils").get_rootdir()
  if rootdir then
    return rootdir .. "/.tox/pep8/bin/:" .. rootdir .. "/node_modules/.bin/:" .. vim.fn.getenv("PATH")
  end
  return vim.fn.getenv("PATH")
end

function M.run_linter()
  local rootdir = require("utils").get_rootdir()
  local env = {PATH = get_local_env_path()}
  local lint = require("lint")
  lint.linters.mypy.args = {
    "--show-column-numbers",
    "--show-error-codes",
    "--show-error-context",
    "--no-color-output",
    "--no-error-summary",
    "--no-pretty"
  }
  lint.linters.flake8.env = env
  lint.linters.mypy.env = env
  lint.linters.eslint.env = env
  lint.try_lint(nil, {cwd = rootdir})
end

function M.setup()
  require("formatter").setup(
    {
      filetype = {
        python = {
          -- Configuration for psf/black and isort
          function()
            return {
              exe = "sh -c 'export PATH=" .. get_local_env_path() .. ";  black -| isort -'",
              args = {},
              stdin = true
            }
          end
        },
        lua = {
          -- luafmt
          function()
            return {
              exe = "luafmt",
              args = {"--indent-count", 2, "--stdin"},
              stdin = true
            }
          end
        }
      }
    }
  )

  require("lint").linters_by_ft = {
    python = {"mypy", "flake8"}
  }

  vim.api.nvim_exec(
    [[
          augroup FormatAndLintAutogroup
          autocmd!
          autocmd BufWritePost *.py FormatWrite
          autocmd BufWritePost *.jsx FormatWrite
          "autocmd BufWritePost *.lua FormatWrite
          autocmd BufWritePost <buffer> lua require("post_write_tools").run_linter()
          autocmd BufReadPost <buffer> lua require("post_write_tools").run_linter()
          augroup END
      ]],
    true
  )
end

return M