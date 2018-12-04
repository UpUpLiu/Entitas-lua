local Bag = require("entitas.Bag")

---@class Signal
local Signal = {}
Signal.__index = Signal
function Signal.new(...)
    local tb = setmetatable({},Signal)
    tb:ctor(...)
    return tb
end
function Signal:ctor(context, alloc)
    alloc = alloc or 16
    self._listeners = Bag.new()
    self._context = context
    self._alloc = alloc
    self.active = false
end


function Signal:dispatch(...)
    local listeners = self._listeners
    local size = listeners:size()
    if (size <= 0) then
        return
    end
    for i = 1, size do
        listeners[i](...)
    end

end

---@param listener function
function Signal:add(listener)
    self._listeners:add(listener)
    self.active = true

end

---@param listener function
function Signal:remove(listener)
    local listeners = self._listeners
    listeners:remove(listener)
    self.active = listeners:size() > 0
end

--------
-- Clear and reset to original alloc
------
function Signal:clear()
    self._listeners:clear()
    self.active = false
end

return Signal