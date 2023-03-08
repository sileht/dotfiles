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

local sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {
        { "filename" },
        {
            function() return require("lsp-status").status() end,
        }
    },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" }
}
require("lualine").setup(
    {
        sections = sections,
        inactive_sections = sections,
        tabline = {
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
    }
)
require("lsp-status").config({
    diagnostics = false,
    status_symbol = "",
})
require("lsp-status").register_progress()
