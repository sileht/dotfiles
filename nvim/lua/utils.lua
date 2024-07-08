local M = {}

function M.get_venvdir(rootdir)
    --local handle = io.popen("poetry env info -p")
    local handle = io.popen("~/.env/bin/poetry-env-info-fast " .. rootdir)
    if handle == nil then
        print("~/.env/bin/poetry-env-info-fast failed")
        return
    end
    local venv = handle:read()
    handle:close()
    if vim.fn.isdirectory(venv) ~= 0 then
        return venv
    end
end

function M.get_venv_binary(rootdir, name, callback)
    local venv = require("utils").get_venvdir(rootdir)
    if venv ~= nil and vim.fn.executable(venv .. "/bin/" .. name) then
        callback(venv .. "/bin/" .. name)
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
    return vim.tbl_map(function(val) return offset .. val end, lines)
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
        { once = true, buffer = bufnr, callback = close, group = augroup }
    )
end

function M.buffer_delete_workaround()
    local buffer = vim.api.nvim_get_current_buf()
    vim.cmd("bn")
    vim.cmd("bdelete " .. buffer)
end

M.focus_mode = false

function M.focus_mode_enabled()
    return M.focus_mode
end

function M.toggle_focus()
    M.focus_mode = not M.focus_mode
    if M.focus_mode then
        --vim.cmd("cclose")
        print("focus layout")
        vim.opt.laststatus = 0
        vim.opt.number = false
        vim.opt.mouse = ""
        vim.opt.relativenumber = false
        vim.opt.signcolumn = "no"
        require("gitsigns.config").config.signcolumn = false
        require("gitsigns.actions").refresh()
        require("scrollview").set_state(false)
        --require("trouble").close()
        vim.opt.cmdheight = 0
    else
        require("scrollview").set_state(true)
        require("gitsigns.actions").refresh()
        require("gitsigns.config").config.signcolumn = true
        vim.opt.signcolumn = "yes"
        vim.opt.relativenumber = true
        vim.opt.mouse = "a"
        vim.opt.number = true
        vim.opt.laststatus = 3
        --require("trouble").open()
        vim.opt.cmdheight = 1
        vim.cmd("wincmd p")
    end
end

M.enhanced_experience_paths = {
    "/Users/sileht/workspace/mergify/engine",
    "/Users/sileht/workspace/mergify/shadow_office",
    "/Users/sileht/workspace/mergify/ui",
    "/Users/sileht/workspace/mergify/docs",
    "/Users/sileht/workspace/mergify/cli",
    "/Users/sileht/workspace/mergify/heroku",
    "/Users/sileht/workspace/mergify/events-forwarder",
    "/Users/sileht/.env/",
}


M.loclist_initiated = false
M.loclist_last_bufnr = nil


function M.loclist_init()
    local name = vim.api.nvim_buf_get_name(0)
    local buftype = vim.fn.getbufvar(vim.fn.bufnr(), "&buftype")
    if buftype ~= "" and name == "" then
        return
    end

    if not M.loclist_initiated then
        M.loclist_initiated = true
        print("init")
        --vim.diagnostic.setqflist({ open = false })
        local window = vim.api.nvim_get_current_win()
        vim.cmd("copen 6")
        vim.api.nvim_set_current_win(window)
    end
end

function M.loclist_update(force)
    local name = vim.api.nvim_buf_get_name(0)
    local bufnr = vim.fn.bufnr()
    local buftype = vim.fn.getbufvar(vim.fn.bufnr(), "&buftype")
    if buftype ~= "" and name == "" then
        --M.loclist_last_bufnr = bufnr
        return
    end

    if force or M.loclist_last_bufnr ~= bufnr then
        --M.loclist_last_bufnr = bufnr
        vim.diagnostic.setqflist({ open = false })
    end
end

return M
