<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts.components
%>\

---@class ${Context_name}Service
local M = {}

function M.init()
end

return M

