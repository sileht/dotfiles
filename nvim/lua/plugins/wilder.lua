return {
    'gelguy/wilder.nvim',
    dependencies = {
        "romgrk/fzy-lua-native"
    },
    config = function()
        vim.keymap.set('c', '<C-d>', '<Nop>')
        local wilder = require('wilder')
        wilder.setup({
            modes = { ':', '/', '?' },
        })
        wilder.set_option('use_python_remote_plugin', 0)
        wilder.set_option('pipeline', {
            wilder.branch(
                wilder.cmdline_pipeline({
                    fuzzy = 1,
                    fuzzy_filter = wilder.lua_fzy_filter(),
                }),
                {
                    wilder.check(function(ctx, x) return x == '' end),
                    wilder.history(),
                },
                wilder.vim_search_pipeline()
            --  wilder.python_search_pipeline({
            --      pattern = wilder.python_fuzzy_pattern({
            --          start_at_boundary = 0,
            --      }),
            --      sorter = wilder.python_difflib_sorter(),
            --  })
            ),
        })
        wilder.set_option('renderer', wilder.popupmenu_renderer({
            min_width = '100%',
            --           wilder.popupmenu_border_theme({
            --wilder.popupmenu_palette_theme({
            prompt_position = 'bottom',
            highlights = {
                accent = wilder.make_hl('WilderAccent', 'Pmenu',
                    { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
            },
            highlighter = {
                wilder.lua_fzy_highlighter()
            },
            left = { ' ', wilder.popupmenu_devicons() },
            right = { ' ', wilder.popupmenu_scrollbar() },
            -- })
        }))
    end,
}
