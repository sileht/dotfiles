local async = require("blink.cmp.lib.async")
local curl = require("plenary.curl")

local issues
local config
local token
local body =
    vim.fn.json_encode(
        {
            query = [[
                    {
                        issues(first: 50, orderBy: updatedAt, filter: {
                            state: { name: { in: ["Todo", "In Progress", "In Review"] } }
                        }) {
                            nodes {
                                identifier title description state{name}
                            }
                        }
                    }
                ]]
        }
    )

---Include the trigger character when accepting a completion.
---@param context blink.cmp.Context
local function transform(items, context)
    return vim.tbl_map(function(entry)
        print(vim.inspect(entry))
        local label = entry.identifier .. ": " .. entry.title .. " [" .. entry.state.name .. "]"
        print(label)
        return {
            label = label,
            kind = require("blink.cmp.types").CompletionItemKind.Text,
            textEdit = {
                range = {
                    start = { line = context.cursor[1] - 1, character = context.bounds.start_col - 2 },
                    ["end"] = { line = context.cursor[1] - 1, character = context.cursor[2] },
                },
                newText = entry.identifier
            },
        }
    end, items)
end

---@type blink.cmp.Source
local M = {}

function M.new(opts)
    local self = setmetatable({}, { __index = M })
    config = vim.tbl_deep_extend("keep", opts or {}, {
        insert = true,
    })
    return self
end

---@param context blink.cmp.Context
function M:get_completions(context, callback)
    print(context.get_keyword())
    if context.get_keyword() ~= "MRGFY-" then
        return
    end

    local task = async.task.empty():map(function()
        if not token then
            local handle = io.popen("security find-generic-password -w -s ENV_LINEAR_TOKEN")
            if not handle then
                print("linear token not found")
                return
            end
            token = handle:read("*a"):gsub("%s+", "")
            handle:close()
        end

        if issues then
            callback({
                is_incomplete_forward = true,
                is_incomplete_backward = true,
                items = transform(issues, context),
                context = context,
            })
        else
            curl.post({
                url = "https://api.linear.app/graphql",
                headers = {
                    accept = "application/json",
                    content_type = "application/json",
                    authorization = token
                },
                body = body,
                callback = function(response)
                    if (response.status ~= 200) then
                        print("linear request failed: " .. response.body)
                        return
                    end
                    local data = vim.json.decode(response.body)
                    issues = data.data.issues.nodes
                    callback({
                        is_incomplete_forward = true,
                        is_incomplete_backward = true,
                        items = transform(issues, context),
                        context = context,
                    })
                end
            })
        end
    end)
    return function()
        task:cancel()
    end
end

---`newText` is used for `ghost_text`, thus it is set to the emoji name in `emojis`.
---Change `newText` to the actual emoji when accepting a completion.
function M:resolve(item, callback)
    local resolved = vim.deepcopy(item)
    if config.insert then
        resolved.textEdit.newText = resolved.insertText
    end
    return callback(resolved)
end

function M:get_trigger_characters()
    return { "-" }
end

return M
