local set           = require("Common.container.set")
local set_insert    = set.insert
local set_remove    = set.remove

---@class EntityMuIndex : entitas.AbstractEntityMuIndex
local M = {}

---@param field entitas.field[]
function M:Ctor(group, field)
    M.__base.Ctor(self, group, field)
end

function M:get_entities(...)
    local fields = {...}
    local t = self._indexes
    for i, key in ipairs(fields) do
        if not t[key] then
            t[key] = {}
        end
        t = t[key]
    end
    return t
end

---@param entity entitas.Entity
function M:_add_entity(fields, entity)
    local t = self._indexes
    local key
    ---@param field entitas.field
    for _, field in ipairs(fields) do
        local comp = entity._components[field.comp_type]
        key = comp[field.key]
        if t[key] == nil then
            t[key] = {}
        end
        t = t[key]
    end
    t[key] = entity
end

function M:_remove_entity(fields, entity)
    local t = self._indexes
    local key
    for comp_type, field in ipairs(fields) do
        key = entity[comp_type][field]
        if t[key] == nil then
            t[key] = {}
        end
        t = t[key]
    end
    t[key] = nil
end

return M
