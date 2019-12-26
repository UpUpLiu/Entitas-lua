--- for luacheck warn: unused params
local ignore_param = function()end

---@class entitas.field
---@field comp_type
---@field key

---@class entitas.AbstractEntityMuIndex
---@field _group entitas.Group
---@field _fields entitas.field[]
local M   = {}

function M:Ctor(group, fields)
    self._group = group
    self._fields = fields
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
        self:_add_entity(self._fields, entity)
    end)
end

function M:_on_entity_added(entity)
    self:_add_entity(self._fields, entity)
end

function M:_on_entity_removed(entity, component)
    self:_remove_entity(self._fields, entity)
end

function M:_add_entity(fields, entity)
    error("not imp")
    ignore_param(self,key,entity)
end

function M:_remove_entity(fields, entity)
    error("not imp")
    ignore_param(self,key,entity)
end

return M
