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

local is_not_diagnostics = function()
    local name = vim.api.nvim_buf_get_name(0)
    local is_trouble = name:match(".*(Trouble)$")
    local is_loclist = name == ""
    return is_trouble == nil and not is_loclist
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
    lualine_z = {},
}
local top_buffer_bar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
}


local bottom_bar = {
    lualine_a = { "mode" },
    lualine_b = {
        { "filetype", icon_only = true, separator = { left = '', right = '' } },
        { "filename" },
        {
            "diagnostics",
            always_visible = false,
        },
        { "diff",   cond = is_not_diagnostics },
        { "branch", cond = is_not_diagnostics },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
        "searchcount", "selectioncount",
        "encoding", "fileformat",
    },
    lualine_z = { "location", "progress" }
}
require("lualine").setup(
    {
        options = {
            theme = 'kanagawa',
            --section_separators = '│',
            component_separators = '│',
            section_separators = { left = ' ', right = ' ' },
            --section_separators = { left = '', right = '' },
        },
        sections = bottom_bar,
        inactive_sections = bottom_bar,
        winbar = top_buffer_bar,
        inactive_winbar = top_buffer_bar,
        tabline = top_sticky_bar,
    }
)
