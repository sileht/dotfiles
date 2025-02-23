return {
    'gelguy/wilder.nvim',
    dependencies = {
        "romgrk/fzy-lua-native"
    },
    config = function()
        local wilder = require('wilder')
        wilder.setup({ modes = { ':', '/', '?' } })
        wilder.set_option('renderer', wilder.popupmenu_renderer(
            {
                highlights = {
                    accent = wilder.make_hl('WilderAccent', 'Pmenu',
                        { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
                },
                highlighter = { wilder.lua_fzy_highlighter() },
                left = { ' ', wilder.popupmenu_devicons() },
                right = { ' ', wilder.popupmenu_scrollbar() },
            }
        ))
    end,
}
