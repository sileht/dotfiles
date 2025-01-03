local source = {}

source.new = function()
    local self = setmetatable({}, { __index = source })
    self.tickets = nil
    return self
end

---Return this M is available in current context or not. (Optional)
---@return boolean
source.is_available = function()
    return vim.bo.filetype == "gitcommit"
end
---Return the debug name of this source. (Optional)
---@return string
source.get_debug_name = function()
    return "linear"
end
---Return keyword pattern for triggering completion. (Optional)
---If this is ommited, nvim-cmp will use default keyword pattern. See |cmp-config.completion.keyword_pattern|
---@return string
source.get_keyword_pattern = function()
    -- return 'MRG.*'
    return [[\%(closes\|resolves\|related\|fixes\)]]
end
---Return trigger characters for triggering completion. (Optional)
source.get_trigger_characters = function()
    return { " " }
end

source.complete = function(self, _, callback)
    local filter = function(v)
        return v
    end

    if (self.tickets ~= nil) then
        callback(vim.tbl_filter(filter, self.tickets))
        return
    end

    local handle = io.popen("security find-generic-password -w -s ENV_LINEAR_TOKEN")
    local token = handle:read("*a")
    token = token:gsub("%s+", "")
    handle:close()
    -- local token = vim.fn.getenv("LINEAR_TOKEN")
    if (token == vim.NIL) then
        return
    end
    local body =
        vim.fn.json_encode(
            {
                query = [[
          {
              issues(first: 10, orderBy: updatedAt, filter: {
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
    local curl = require("plenary.curl")
    curl.request(
        {
            method = "post",
            url = "https://api.linear.app/graphql",
            headers = {
                accept = "application/json",
                content_type = "application/json",
                authorization = token
            },
            body = body,
            callback = vim.schedule_wrap(
                function(response)
                    if (response.status ~= 200) then
                        print("linear request failed: " .. response.body)
                        return
                    end
                    local data = vim.fn.json_decode(response.body)
                    local items = {}
                    for _, node in ipairs(data.data.issues.nodes) do
                        local label = node.identifier .. ": " .. node.title .. " [" .. node.state.name .. "]"
                        table.insert(
                            items,
                            {
                                kind = 18,
                                label = label,
                                insertText = node.identifier
                            }
                        )
                    end
                    self.tickets = items
                    callback(vim.tbl_filter(filter, items))
                end
            )
        }
    )
end
source.resolve = function(_, completion_item, callback)
    callback(completion_item)
end
source.execute = function(_, completion_item, callback)
    callback(completion_item)
end

source.setup = function()
    ---Register custom M to nvim-cmp.
    require("cmp").register_source("linear", source.new())
end
return source
