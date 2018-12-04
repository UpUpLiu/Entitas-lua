local AbstractEntityIndex = require("entitas.AbstractEntityIndex")
local utils = require("entitas.util")

---@class _PrimaryEntityIndex : _AbstractEntityIndex
local PrimaryEntityIndex = utils.class("PrimaryEntityIndex", AbstractEntityIndex)

function PrimaryEntityIndex:ctor(comp_index, group, ...)
    PrimaryEntityIndex.super.ctor(self, comp_index, group, ...)
end

function PrimaryEntityIndex:getEntity(key)
    return self._indexes[key]
end

function PrimaryEntityIndex:addEntity(key, entity)
    if self._indexes[key] then
        error(string.format("Entity for key '%s' already exists ! Only one entity for a primary key is allowed.", key))
    end
    self._indexes[key] = entity
    entity:addRef(self)
end

function PrimaryEntityIndex:removeEntity(key , entity)
    self._indexes[key] = nil
    entity:release(self)
end

return PrimaryEntityIndex