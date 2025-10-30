return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        {
            'nvim-telescope/telescope-ui-select.nvim',
        },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build =
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        { "nvim-telescope/telescope-file-browser.nvim" },
        { "nvim-telescope/telescope-fzf-native.nvim" },
        {
            "danielfalk/smart-open.nvim",
            branch = "0.2.x",
            dependencies = {
                "kkharji/sqlite.lua",
                { "nvim-telescope/telescope-fzf-native.nvim" },
            },
        }
    },
    config = function()
        local defaults = require("telescope.themes").get_ivy({})
        defaults.prompt_prefix = " ❯ "
        defaults.selection_caret = " ❯ "
        defaults.entry_prefix = "   "
        defaults.find_command = { "fd", "-t=f", "-a" }
        defaults.path_display = { "smart" }
        defaults.wrap_results = true
        require("telescope").setup({
            defaults = defaults,
            extensions = {
                smart_open = {
                    match_algorithm = "fzf",
                },
            },
        })
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("file_browser")
        require("telescope").load_extension("smart_open")
        require("telescope").load_extension("ui-select")
    end
}
