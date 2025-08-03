local M = {}
M.toggle_fstring = function()
    local current_buf = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = current_buf })

    if not vim.tbl_contains({ "javascript", "typescript", "python" }, filetype) then
        return
    end

    local ts_utils = require("nvim-treesitter.ts_utils")
    local winnr = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(winnr)
    local node = ts_utils.get_node_at_cursor()

    print(node:type())
    while (node ~= nil) and (
            node:type() ~= "string"
            and node:type() ~= "string_fragment"
            and node:type() ~= "template_literal_type"
        ) do
        node = node:parent()
    end

    if node == nil then
        print("f-string-toggle: could not detect string to change!")
        return
    end

    if (node:type() == "string_fragment") then
        node = node:parent()
    end

    local srow, scol, ecol, erow = ts_utils.get_vim_range({ node:range() })
    vim.fn.setcursorcharpos({ srow, scol })
    local char = vim.api.nvim_get_current_line():sub(scol, scol)

    local offset
    if filetype == "python" then
        local is_fstring = (char == "f")
        if is_fstring then
            vim.cmd("normal x")
            offset = -1
        else
            vim.cmd("normal if")
            offset = 1
        end
        -- Move the cursor if on the same line
        if srow == cursor[1] then
            cursor[2] = cursor[2] + offset
        end
    elseif vim.tbl_contains({ "javascript", "typescript" }, filetype) then
        local replace_char
        if char == "`" then
            replace_char = "'"
        elseif char == "'" or char == "\"" then
            replace_char = "`"
        end
        vim.cmd("normal r" .. replace_char .. "f" .. char .. "r" .. replace_char .. "")
    end

    vim.api.nvim_win_set_cursor(winnr, cursor)
end
return M
