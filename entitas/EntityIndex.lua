local AbstractEntityIndex = require("entitas.AbstractEntityIndex")
local util = require("entitas.util")
local unorderset = require("entitas.unorderset")
local set_insert = unorderset.insert
local set_remove = unorderset.remove


---@class _EntityIndex : _AbstractEntityIndex
local EntityIndex = util.class("EntityIndex", AbstractEntityIndex)

function EntityIndex:ctor(comp_index, group, ...)
    EntityIndex.super.ctor(self, comp_index, group, ...)
end

function EntityIndex:getEntities(key)
    if not self._indexes[key] then
        self._indexes[key] = unorderset.new()
    end
    return self._indexes[key]
end

function EntityIndex:addEntity(key , entity)
    --print(tostring(key), entity)
    local t = self:getEntities(key)
    set_insert(t, entity)
    entity:addRef(self)
end

function EntityIndex:removeEntity(key, entity)
    local t = self:getEntities(key)
    set_remove(t, entity)
    entity:release(self)
end

return EntityIndex