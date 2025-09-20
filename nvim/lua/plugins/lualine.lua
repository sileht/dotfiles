local toggler = function(name, method)
    return {
        function()
            return (method() and "" or "") .. " " .. name
        end,
        color = function()
            return {
                fg = method() and '#AAB1BE' or '#788293'
            }
        end

    }
end

local top_tabbar = function()
    return {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    }
end

local top_winbar = function()
    return {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    }
end

local bottom_bar = function()
    return {
        lualine_a = { "mode" },
        lualine_b = {
            { "branch" },
            { "diff" },
        },
        lualine_c = {
            { require("gitblame").get_current_blame_text, cond = require("gitblame").is_blame_text_available } },
        lualine_x = {},
        lualine_y = {
            "searchcount", "selectioncount",
            toggler("Format", require("formatter").enabled_on_current_buffer),
            "filetype",
            "fileformat",
            "encoding",
        },
        lualine_z = { "location", "progress", function() return " " end }
    }
end

return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require('lualine').setup({
            options = {
                theme = "moonfly",
                component_separators = '│',
                section_separators = { left = ' ', right = ' ' },
            },
            sections = bottom_bar(),
            inactive_sections = bottom_bar(),
            --winbar = top_winbar(),
            --inactive_winbar = top_winbar(),
            --tabline = top_tabbar(),
        })
    end
}
