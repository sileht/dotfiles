M = {}

local get_python_venvdir = function()
  local rootdir = require("utils").get_rootdir()
  if rootdir then
    return rootdir .. "/.tox/pep8/bin/"
  else
    return ""
  end
end

function M.run_linter()
  local rootdir = require("utils").get_rootdir()
  local prefix = get_python_venvdir()
  require("lint.linters.flake8").cmd = prefix .. "flake8"
  require("lint.linters.mypy").cmd = prefix .. "mypy"
  require("lint.linters.mypy").cwd = rootdir
  require("lint").try_lint()
end

function M.setup()
  require("formatter").setup(
    {
      filetype = {
        python = {
          -- Configuration for psf/black and isort
          function()
            return {
              exe = "sh -c 'export PATH=" .. get_python_venvdir() .. ":$PATH ;  black -| isort -'",
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
          autocmd BufWritePost *.py,*.jsx,*.lua FormatWrite
          "autocmd BufWritePost *.py,*.jsx FormatWrite
          autocmd BufWritePost <buffer> lua require("post_write_tools").run_linter()
          augroup END
      ]],
    true
  )
end

return M
