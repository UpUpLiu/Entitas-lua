local utils = require("entitas.util")

---@class _AbstractEntityIndex
---@field group Group
---@field _index _Entity[]
local AbstractEntityIndex = utils.class("_AbstractEntityIndex")

function AbstractEntityIndex:ctor(index, group, ...)
    self.comp_index = index
    self.group = group
    self._fields = {...}
    self._indexes = {}
    self.on_entity_added = function(...) return self:onEntityAdded(...) end
    self.on_entity_removed = function(...) return self:onEntityRemoved(...) end
    self:_activate()
    local mt = getmetatable(self)
    mt.__gc = function(t) t:_deactivate() end
end

function AbstractEntityIndex:_activate()
    self.group.onEntityAdded:add(self.on_entity_added)
    self.group.onEntityRemoved:add(self.on_entity_removed)
    self:indexEntities()
end

function AbstractEntityIndex:_deactivate()
    self.group.onEntityAdded:remove(self.on_entity_added)
    self.group.onEntityRemoved:remove(self.on_entity_removed)
    self._indexes = {}
end


---@param group Group
function AbstractEntityIndex:indexEntities()
    local entitas = self.group:getEntities()
    local index = self.comp_index
    for _, entity in pairs(entitas) do
        local component = entity:getComponent(index)
        for _, field in pairs(self._fields) do
            self:addEntity(component[field], entity)
        end
    end
end

---@param group Group
function AbstractEntityIndex:onEntityAdded(group,entity, index, component)
    for _, field in pairs(self._fields) do
        self:addEntity(component[field], entity)
    end
end

---@param group Group
function AbstractEntityIndex:onEntityRemoved(group, entity, index,component)
    for _, field in pairs(self._fields) do
        self:removeEntity(component[field], entity)
    end
end

function AbstractEntityIndex:addEntity()
    error("not imp")
end

function AbstractEntityIndex:removeEntity()
    error("not imp")
end

function AbstractEntityIndex:clear()

end

return AbstractEntityIndex