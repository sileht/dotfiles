return {
    init_options = {
        diagnostics = { enable = true },
        jediSettings = { debug = false },
        completion = {
            disableSnippets = true,
            resolveEagerly = true,
        },
    },
    before_init = function(init_params, config)
        local venv = require("utils").get_venvdir(config.root_dir)
        if venv ~= nil then
            init_params.initializationOptions.workspace = { environmentPath = venv .. "/bin/python" }
        end
    end,
}
