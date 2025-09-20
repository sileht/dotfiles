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

M.focus_mode = false

function M.focus_mode_enabled()
    return M.focus_mode
end

function M.toggle_focus()
    M.focus_mode = not M.focus_mode
    if M.focus_mode then
        print("focus layout")
        vim.opt.laststatus = 0
        vim.opt.number = false
        vim.opt.mouse = ""
        vim.opt.relativenumber = false
        vim.opt.signcolumn = "no"
        require("gitsigns.config").config.signcolumn = false
        require("gitsigns.actions").refresh()
        vim.opt.cmdheight = 0
    else
        require("gitsigns.actions").refresh()
        require("gitsigns.config").config.signcolumn = true
        vim.opt.signcolumn = "yes"
        vim.opt.relativenumber = true
        vim.opt.mouse = "a"
        vim.opt.number = true
        vim.opt.laststatus = 3
        vim.opt.cmdheight = 1
        vim.cmd("wincmd p")
    end
end

function M.get_secret(name)
    local handle = io.popen("security find-generic-password -w -s " .. name)
    if not handle then
        print(name .. " not found")
        return
    end
    secret = handle:read("*a"):gsub("%s+", "")
    handle:close()
    return secret
end

return M
