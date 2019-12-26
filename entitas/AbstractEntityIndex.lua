--- for luacheck warn: unused params
local ignore_param = function()end
---@class entitas.AbstractEntityIndex
---@field _group entitas.Group
local M   = {}

function M:Ctor(comp_type, group, ...)
    self.comp_type = comp_type
    self._group = group
    self._fields = {...}
    self._indexes = {}
    self:_activate()
    local mt = getmetatable(self)
    mt.__gc = function(t) t:_deactivate() end
end

function M:_activate()
    self._group.on_entity_added:add(self._on_entity_added, self)
    self._group.on_entity_removed:add(self._on_entity_removed, self)
    self._group.on_entity_updated:add(self._on_entity_added, self)
    self:_index_entities()
end

function M:_deactivate()
    self._group.on_entity_added:remove(self._on_entity_added)
    self._group.on_entity_removed:remove(self._on_entity_removed)
    self._group.on_entity_updated:remove(self._on_entity_added)
    self._indexes = {}
end

function M:_index_entities()
    self._group.entities:foreach(function(entity)
        local comp_type = entity:get(self.comp_type)
        for _, field in pairs(self._fields) do
            self:_add_entity(comp_type[field], entity)
        end
    end)
end

function M:_on_entity_added(entity, component)
    if not self.comp_type._is(component)then
        return
    end

    for _, field in pairs(self._fields) do
        self:_add_entity(component[field], entity)
    end
end

function M:_on_entity_removed(entity, component)
    if not self.comp_type._is(component)then
        return
    end

    for _, field in pairs(self._fields) do
        self:_remove_entity(component[field], entity)
    end
end

function M:_add_entity(key, entity)
    error("not imp")
    ignore_param(self,key,entity)
end

function M:_remove_entity(key, entity)
    error("not imp")
    ignore_param(self,key,entity)
end

return M
