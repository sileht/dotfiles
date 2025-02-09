return {
    "nvim-treesitter/nvim-treesitter",
    --event = "VeryLazy",
    build = ":TSUpdateSync",
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            enabled = false,
        }
    },
    config = function()
        require("nvim-treesitter.configs").setup(
            {
                ensure_installed = "all",
                ignore_install = { "phpdoc", "wgsl" },
                indent = { enable = true },
                incremental_selection = { enable = true },
                highlight = { enable = true, additional_vim_regex_highlighting = true },
                textobjects = {
                    select = {
                        enable = true,
                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner"
                        }
                    }
                }
            }
        )
    end
}
