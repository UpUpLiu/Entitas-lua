local set = require("Common.container.set")
local set_insert = set.insertkv
local set_remove = set.remove

---@class entitas.Delegate
local M = {}

M.__index = M

M.__call = function(t, ...)
    for k, target in pairs(t._listeners._data) do
        k(target, ...)
    end
end

function M.new()
    local tb = {}
    tb._listeners = set.new()
    return setmetatable(tb, M)
end

function M:add(f, target)
    assert(set_insert(self._listeners, f, target))
end

function M:remove( f)
    return set_remove(self._listeners, f)
end

function M:has( f)
    return self._listeners:has(f)
end

return M
