M = {}
M.enabled = false

local get_local_env_path = function()
    local rootdir = require("utils").get_rootdir()
    local venv = require("utils").get_venvdir(rootdir)
    local path = ""
    if venv ~= nil then
        path = path .. venv .. "/bin:"
    end
    node_modules_bin = rootdir .. "/node_modules/.bin"
    if vim.fn.isdirectory(node_modules_bin) ~= 0 then
        path = path .. node_modules_bin .. ":"
    end
    path = path .. vim.fn.getenv("PATH")
    return path
end

function M.run_linter()
    local rootdir = require("utils").get_rootdir()
    local python_venv_bin = ""

    if rootdir ~= nil then
        local venv = require("utils").get_venvdir(rootdir)
        if venv ~= nil then
            python_venv_bin = venv .. "/bin/"
        end
    end

    local lint = require("lint")
    --lint.linters.mypy.ignore_exitcode = false
    lint.linters.mypy.cmd = python_venv_bin .. "mypy"
    lint.linters.mypy.args = {
        "--show-column-numbers",
        "--show-error-codes",
        "--show-error-context",
        "--no-color-output",
        "--no-error-summary",
        "--no-pretty"
    }
    lint.linters.flake8.cmd = python_venv_bin .. "flake8"
    lint.try_lint(nil, { cwd = rootdir })
end

function M.setup()
    local py_auto_formats = {
        --"autoflake --remove-all-unused-imports -s -",
        "black --fast - ",
        "isort -"
    }
    require("formatter").setup(
        {
            filetype = {
                python = {
                    function()
                        return {
                            exe = "sh -c '" .. table.concat(py_auto_formats, " | ") .. "'",
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
                            args = { "--indent-count", 2, "--stdin" },
                            stdin = true
                        }
                    end
                }
            }
        }
    )
    require("lint").linters_by_ft = {
        python = { "mypy", "flake8" }
        --python = {"flake8"}
    }
    M.enable()
end

function M.enable()
    vim.api.nvim_exec(
        [[
          augroup FormatAndLintAutogroup
          autocmd!
          autocmd BufWritePost *.py FormatWrite
          "autocmd BufWritePost *.lua FormatWrite
          "autocmd BufWritePost *.jsx FormatWrite
          "autocmd BufWritePost *.tsx FormatWrite
          "autocmd BufWritePost *.ts FormatWrite
          "autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll
          autocmd BufWritePost * lua require("post_write_tools").run_linter()
          autocmd BufReadPost * lua require("post_write_tools").run_linter()
          augroup END
      ]] ,
        true
    )
    M.enabled = true
end

function M.disable()
    vim.api.nvim_exec([[
          augroup FormatAndLintAutogroup
          autocmd!
          augroup END
      ]], true)
    M.enabled = false
end

function M.toggle()
    if M.enabled then
        M.disable()
        print("post write tools disabled")
    else
        M.enable()
        print("post write tools enabled")
    end
end

return M
