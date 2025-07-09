local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local extension = { exports = {} }

extension.setup = function(config)
    extension.config = require "telescope.themes".get_ivy { config }
end

extension.exports.prflow = function(opts)
    opts = vim.tbl_deep_extend("force", extension.config, opts or {})

    local tasks = {
        { cmd = "Git commit -a" },
        { cmd = "Git commit --amend -a" },
        { shell = "mergify push stack -k" },
        { shell = "mergify push stack -k -R" },
    }
    local picker = pickers.new(opts, {
        prompt_title = "poe ...",
        finder = finders.new_table({
            results = tasks,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.cmd or entry.shell,
                    ordinal = entry.cmd or entry.shell,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(bufnr)
            actions.select_default:replace(function()
                actions.close(bufnr)
                local selection = action_state.get_selected_entry()
                if selection.value.shell ~= nil then
                    vim.cmd("split | terminal " .. selection.value.shell)
                else
                    vim.cmd(selection.value.cmd)
                end
            end)
            return true
        end
    })

    picker:find()
end


return require("telescope").register_extension(extension)
