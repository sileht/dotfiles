local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.tickets = nil
  return self
end

---Return this M is available in current context or not. (Optional)
---@return boolean
source.is_available = function(self)
  return true
end
---Return the debug name of this source. (Optional)
---@return string
source.get_debug_name = function(self)
  return 'linear'
end
---Return keyword pattern for triggering completion. (Optional)
---If this is ommited, nvim-cmp will use default keyword pattern. See |cmp-config.completion.keyword_pattern|
---@return string
source.get_keyword_pattern = function(self)
  -- return 'MRG.*'
  return [[\%(closes\|resolves\|related\|fixes\)]]
end
---Return trigger characters for triggering completion. (Optional)
source.get_trigger_characters = function(self)
  return { ' ' }
end

---Invoke completion. (Required)
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
source.complete = function(self, params, callback)
  local filter = function(v)
      return v
  end

  if (self.tickets ~= nil) then
      callback(vim.tbl_filter(filter, self.tickets))
      return
  end

  local token = vim.fn.getenv("LINEAR_TOKEN")
  print(token)
  if (token == vim.NIL) then
      return
  end
  local body = vim.fn.json_encode({
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
  })
  local curl = require("plenary.curl")
  curl.request({
    method = "post",
    url = "https://api.linear.app/graphql",
    headers = {
      accept = "application/json",
      content_type = "application/json",
      authorization = token,
    },
    body = body,
   callback = vim.schedule_wrap(function(response)
        if (response.status ~= 200) then
            print("linear request failed: " .. response.body)
            return
        end
        local data = vim.fn.json_decode(response.body)
        local items = {}
        for _, node in ipairs(data.data.issues.nodes) do
            local label = node.identifier .. ": " .. node.title .. " [" .. node.state.name .. "]"
            table.insert(items, {
                kind = 18,
                label = label,
                insertText = node.identifier,
            })
        end
        self.tickets = items
        callback(vim.tbl_filter(filter, items))
    end)
  })
end
---Resolve completion item. (Optional)
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
source.resolve = function(self, completion_item, callback)
  callback(completion_item)
end
---Execute command after item was accepted.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
source.execute = function(self, completion_item, callback)
  callback(completion_item)
end

---Register custom M to nvim-cmp.
require('cmp').register_source('linear', source.new())
