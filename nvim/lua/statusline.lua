local toggler = function(name, module, var)
    local toggler_text = function()
        if require(module)[var]() then
            return name .. " "
        else
            return name .. " "
        end
    end
    local toggler_color = function()
        return { fg = require(module)[var]() and '' or '#5e6c77' }
    end
    return { toggler_text, color = toggler_color }
end

local is_not_trouble = function()
    local is_trouble = vim.api.nvim_buf_get_name(0):match(".*(Trouble)$")
    return is_trouble == nil
end

local top_sticky_bar = {
    lualine_a = { "buffers" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {
        toggler("Formatter", "formatter", "enabled"),
        toggler("Focus", "utils", "focus_mode_enabled"),
    },
    lualine_y = {},
    lualine_z = { "tabs" }
}
local top_buffer_bar = {
    lualine_a = {},
    lualine_b = {
        { "branch", cond = is_not_trouble },
        { "diff",   cond = is_not_trouble },
    },
    lualine_c = {
        { "navic", cond = is_not_trouble }
    },
    lualine_x = {},
    lualine_y = { "diagnostics" },
    lualine_z = {},
}


local bottom_bar = {
    lualine_a = { "mode" },
    lualine_b = { "filename" },
    lualine_c = { "searchcount", "selectioncount" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" }
}
require("lualine").setup(
    {
        options = { theme = 'auto' },
        sections = bottom_bar,
        inactive_sections = bottom_bar,
        winbar = top_buffer_bar,
        inactive_winbar = top_buffer_bar,
        tabline = top_sticky_bar,
    }
)
require("fidget").setup()
