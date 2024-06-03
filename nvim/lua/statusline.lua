local toggler = function(name, module, var)
    return {
        function()
            return name .. " " .. (require(module)[var]() and "" or "")
        end,
        color = function()
            return {
                fg = require(module)[var]() and '#D4CEAC' or '#5E6C77'
            }
        end

    }
end

local top_tabbar = {
    lualine_a = {
        "buffers",
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
}
local top_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {
        --{ "diagnostics", always_visible = true },
        toggler("Formatter", "formatter", "enabled"),
        toggler("Focus", "utils", "focus_mode_enabled"),
    },
    lualine_y = {},
    lualine_z = {},
}


local bottom_bar = {
    lualine_a = { "mode" },
    lualine_b = {
        { "branch" },
        { "diff" },
        -- { "filetype", icon_only = true,         separator = { left = '', right = '' } },
        --{ "filename" },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
        "searchcount", "selectioncount",
        "filetype",
        "fileformat",
        "encoding",
    },
    lualine_z = { "location", "progress" }
}
require("lualine").setup(
    {
        options = {
            --theme = 'kanagawa',
            section_separators = ' ',
            component_separators = '│',
            --section_separators = { left = ' ', right = ' ' },
            --section_separators = { left = ' ', right = ' ' },
            --section_separators = { left = '', right = '' },
        },
        sections = bottom_bar,
        inactive_sections = bottom_bar,
        winbar = top_winbar,
        inactive_winbar = top_winbar,
        --tabline = top_tabbar,
    }
)
