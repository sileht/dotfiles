local M = {}
function M.dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

function M.get_venvdir(rootdir)
    --local handle = io.popen("poetry env info -p")
    local handle = io.popen("~/.bin/poetry-env-info-fast " .. rootdir)
    if handle == nil then
        print("~/.bin/poetry-env-info-fast failed")
        return
    end
    local venv = handle:read()
    handle:close()
    if vim.fn.isdirectory(venv) ~= 0 then
        return venv
    end
end

function M.get_rootdir()
    local lspconfig = require("lspconfig")
    local rootdir = lspconfig.util.root_pattern(
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".git",
            ".venv",
            "package.json"
        )(vim.api.nvim_buf_get_name(0))
    return rootdir
end

local function indent_lines(lines, offset)
    return vim.tbl_map(
        function(val)
            return offset .. val
        end,
        lines
    )
end

function M.create_popup(name, what)
    what = vim.deepcopy(what)

    if type(what) == "string" then
        what = { what }
    else
        assert(type(what) == "table", '"what" must be a table')
    end

    local windows = require "lspconfig.ui.windows"
    local win_info = windows.percentage_range_window(0.8, 0.7, { wrap = true })
    local bufnr, win_id = win_info.bufnr, win_info.win_id

    what = vim.list_extend({ "Use [q] or [Esc] to quit the window", "" }, what)
    local fmt_buf_lines = indent_lines(what, " ")
    fmt_buf_lines = vim.lsp.util._trim(fmt_buf_lines, {})

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, fmt_buf_lines)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "lspinfo")
    vim.api.nvim_buf_add_highlight(bufnr, 0, "LspInfoTip", 0, 0, -1)

    local augroup = vim.api.nvim_create_augroup(name, { clear = false })
    local function close()
        vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
        if vim.api.nvim_win_is_valid(win_id) then
            vim.api.nvim_win_close(win_id, true)
        end
    end

    vim.keymap.set("n", "<ESC>", close, { buffer = bufnr, nowait = true })
    vim.keymap.set("n", "q", close, { buffer = bufnr, nowait = true })
    vim.api.nvim_create_autocmd(
        { "BufDelete", "BufLeave", "BufHidden" },
        {
            once = true,
            buffer = bufnr,
            callback = close,
            group = augroup
        }
    )
end

function M.buffer_delete_workaround()
    local buffer = vim.api.nvim_get_current_buf()
    vim.cmd("bn")
    vim.cmd("bdelete " .. buffer)
end

M.formatter = true
M.may_format = vim.lsp.buf.format
M.focus_mode = false


function M.toggle_formatter()
    M.formatter = not M.formatter
    if M.formatter then
        print("formatter tools enabled")
        M.may_format = vim.lsp.buf.format
    else
        print("formatter tools disabled")
        M.may_format = function() end
    end
end

function M.toggle_focus()
    M.focus_mode = not M.focus_mode
    if M.focus_mode then
        --vim.cmd("cclose")
        print("focus layout")
        vim.opt.laststatus = 0
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = "no"
        require("gitsigns.config").config.signcolumn = false
        require("gitsigns.actions").refresh()
        require("scrollview").scrollview_disable()
        require("trouble").close()
        vim.opt.cmdheight = 0
    else
        require("scrollview").scrollview_enable()
        require("gitsigns.actions").refresh()
        require("gitsigns.config").config.signcolumn = true
        vim.opt.signcolumn = "yes"
        vim.opt.relativenumber = true
        vim.opt.number = true
        vim.opt.laststatus = 3
        require("trouble").open()
        vim.opt.cmdheight = 1
        vim.cmd("wincmd p")
    end
end

return M
