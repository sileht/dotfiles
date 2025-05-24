local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local extension = { exports = {} }

extension.setup = function(config)
    if config.theme then
        extension.config = require "telescope.themes"['get_' .. config.theme] { config }
    else
        extension.config = require "telescope.themes".get_dropdown { config }
    end

    extension.config.action = config.action or vim.fn.system
end

local function get_tasks()
    local handle = io.popen("poe --help")
    if not handle then return {} end

    local output = handle:read("*a")
    handle:close()

    local tasks = {}
    local in_tasks_section = false

    for line in output:gmatch("[^\r\n]+") do
        if line:match("^Configured tasks:") then
            in_tasks_section = true
        elseif in_tasks_section then
            if line:match("^%s*$") then break end

            local name, desc = line:match("^%s*(%S+)%s+(.+)$")
            if name then
                table.insert(tasks, { name = name, desc = desc })
            else
                -- fallback for tasks with no description
                name = line:match("^%s*(%S+)")
                if name then table.insert(tasks, { name = name, desc = "" }) end
            end
        end
    end

    return tasks
end

extension.exports.poethepoet = function(opts)
    opts = vim.tbl_deep_extend("force", extension.config, opts or {})

    local tasks = get_tasks()
    local picker = pickers.new(opts, {
        prompt_title = "poe ...",
        finder = finders.new_table({
            results = tasks,
            entry_maker = function(entry)
                return {
                    value = entry.name,
                    display = string.format("%-20s  %s", entry.name, entry.desc),
                    ordinal = entry.name .. " " .. entry.desc,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(bufnr)
            actions.select_default:replace(function()
                actions.close(bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd("split | terminal poe " .. selection.value)
            end)
            return true
        end
    })

    picker:find()
end


return require("telescope").register_extension(extension)
