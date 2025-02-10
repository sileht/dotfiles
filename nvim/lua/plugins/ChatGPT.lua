return {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
    },
    opts = {
        openai_params = {
            model = "o1-mini"
        },
        api_key_cmd = "security find-generic-password -w -s ENV_OPENAI_TOKEN"
    }
}
