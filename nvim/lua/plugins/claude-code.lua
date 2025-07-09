return {
    "greggh/claude-code.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("claude-code").setup({
            window = {
                split_ratio = 0.5,
                position = "vertical",
            }
        }
        )
    end
}
