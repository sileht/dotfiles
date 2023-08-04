M = {}

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
    lint.linters_by_ft = {
        python = { "mypy" }
    }
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
    -- lint.linters.flake8.cmd = python_venv_bin .. "flake8"
    lint.try_lint(nil, { cwd = rootdir })
end

return M
