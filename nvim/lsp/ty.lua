return {
    settings = {
        pyrefly = {
            disableLanguageServices = false,
            disableTypeErrors = true,
        }
    },
    before_init = function(init_params, config)
        local venv = require("utils").get_venvdir(config.root_dir)
        if venv ~= nil then
            config.cmd = vim.fn.extend(config.cmd, { "--venv", venv .. "/bin/python" })
        end
    end,
}
