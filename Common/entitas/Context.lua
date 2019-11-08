local Entity        = import(".Entity")
local Group         = import(".Group")
local Matcher       = import(".Matcher")

local table_insert  = table.insert
local table_remove  = table.remove

--[[
    The Context is the factory where you create and destroy entities.
    Use it to filter entities of interest.
]]
---@class entitas.Context
---@field entities table<number, entitas.Entity>
---@field _groups table<entitas.Matcher, entitas.Group>
local M = {}

--M.__index = M

function M:Ctor(entity_class)
    local tb = {}
    -- Entities retained by this context.
    self.entities = {}
    -- An object pool to recycle entities.
    self._entities_pool = {}
    self._entity_class = entity_class
    -- Entities counter
    self._uuid = 1
    self._size = 0
    -- Dictionary of matchers mapping groups.
    self._groups = {}
    self._entity_indices = {}
    self.comp_added = function(...) return self:_comp_added( ...) end
    self.comp_removed = function(...) return self:_comp_removed( ...) end
    self.comp_replaced = function(...) return self:_comp_replaced( ...) end
    --return setmetatable(tb, M)
end

-- Checks if the context contains this entity.
function M:has_entity(entity)
    return self.entities[entity._uid]
end

--[[
Creates an entity. Pop one entity from the pool if it is not
empty, otherwise creates a new one. Increments the entity index.
Then adds the entity to the list.
:rtype: Entity
]]
function M:create_entity()
    local entity = table_remove(self._entities_pool)
    if not entity then
        entity = self:_create_entity()
        entity.on_component_added:add(self.comp_added)
        entity.on_component_removed:add(self.comp_removed)
        entity.on_component_replaced:add(self.comp_replaced)
    end

    entity:_activate(self._uuid)
    self._uuid = self._uuid + 1
    self.entities[entity._uid] = entity
    self._size = self._size + 1
    return entity
end

function M:_create_entity()
    assert(false)
end

--[[
Removes an entity from the list and add it to the pool. If
the context does not contain this entity, a
:class:`MissingEntity` exception is raised.
:param entity: Entity
]]
function M:destroy_entity(entity)
    if not self:has_entity(entity) then
        error("The context does not contain this entity:"..tostring(entity))
    end

    entity:_destroy()

    self.entities[entity._uid] = nil
    table_insert(self._entities_pool, entity)
    self._size = self._size - 1
end

function M:entity_size()
    return self._size
end

--[[
User can ask for a group of entities from the context. The
group is identified through a :class:`Matcher`.
:param entity: Matcher
]]
---@return entitas.Group
function M:get_group(matcher)
    local group = self._groups[matcher]
    if group then
        return group
    end

    group = Group.new(matcher)

    for _,e in pairs(self.entities) do
        group:handle_entity_silently(e)
    end

    self._groups[matcher] = group

    return group
end

function M:set_unique_component(name, comp_type, ...)
    local entity = self:create_entity()
    local new_comp = comp_type.new(...)
    self[name .. 'Entity'] = entity
    self[name] = new_comp
    local comp = entity:add_with_component(comp_type, new_comp)
    return comp, entity
end

function M:get_unique_component(comp_type)
    local group = self:get_group(Matcher({comp_type}))
    local entity = group:single_entity()
    return entity:get(comp_type)
end

function M:has_unique_component(comp_type)
    local group = self:get_group(Matcher({comp_type}))
    local entity = group:single_entity()
    if entity == nil then
        return false
    end
    return entity:get(comp_type) ~= nil
end


function M:remove_unique_component(name)
    local old = self[name .. 'Entity']
    self[name .. 'Entity'] = nil
    self[name] = nil
    self:destroy_entity(old)
end

function M:add_entity_index(entity_index)
    self._entity_indices[entity_index.comp_type] = entity_index
end

function M:get_entity_index(comp_type)
    return self._entity_indices[comp_type]
end

function M:_comp_added(entity, comp_value)
    for _, group in pairs(self._groups) do
        local ret = group:handle_entity(entity)
        if ret then
            ret(entity, comp_value)
        end
        --if group._matcher:match_one(comp_value) then
        --    group:handle_entity(entity, comp_value)
        --end
    end
end

function M:_comp_removed(entity, comp_value)
    for _, group in pairs(self._groups) do
        local ret = group:handle_entity(entity)
        if ret then
            ret(entity, comp_value)
        end
    end
end

function M:_comp_replaced(entity, comp_value)
    for _, group in pairs(self._groups) do
        if group._matcher:match_one(comp_value) then
            group:update_entity(entity, comp_value)
        end
    end
end

return M
