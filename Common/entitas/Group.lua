local Delegate = import(".Delegate")
local set = require("Common.container.set")
local set_insert = set.insert
local set_remove = set.remove
local set_size = set.size
local table_insert = table.insert
---@class entitas.Group
---@field on_entity_added entitas.Delegate
---@field on_entity_removed entitas.Delegate
---@field on_entity_updated entitas.Delegate
---@field _matcher entitas.Matcher
---@field entities entitas.Set
local M = {}

--[[
Use context.get_group(matcher) to get a group of entities which
match the specified matcher. Calling context.get_group(matcher) with
the same matcher will always return the same instance of the group.

The created group is managed by the context and will always be up to
date. It will automatically add entities that match the matcher or
remove entities as soon as they don't match the matcher anymore.
]]
M.__index = M

M.__tostring = function(t)
    return string.format("<Group [{%s}]>", tostring(t._matcher))
end

function M.new(matcher)
    local tb = {}
    -- Occurs when an entity gets added.
    tb.on_entity_added = Delegate.new()
    -- Occurs when an entity gets removed.
    tb.on_entity_removed = Delegate.new()
    -- Occurs when a component of an entity in the group gets replaced.
    tb.on_entity_updated = Delegate.new()
    tb._matcher = matcher
    tb.entities = set.new(true)
    return setmetatable(tb, M)
end

--[[
Returns the only entity in this group.
It will return None if the group is empty.
It will throw a :class:`MissingComponent` if the group has more
than one entity.
]]
function M:single_entity()
    local count = set.size(self.entities)

    if count == 1 then
        return self.entities:at(1)
    end

    if count == 0 then
        return nil
    end

    error(string.format("Cannot get a single entity from a group containing %d entities", count))
end

function M:entity_size()
    return set_size(self.entities)
end

function M:get_entity_buffer()
    local ret = {}
    local entities = self.entities._data
    for entity, _ in pairs(entities) do
        table_insert(ret, entity)
    end
    return ret
end


--[[
This is used by the context to manage the group.
:param matcher: Entity
]]
function M:handle_entity_silently(entity)
    assert(entity)
    if self._matcher:match_entity(entity) then
        return self:_add_entity_silently(entity)
    else
        return self:_remove_entity_silently(entity)
    end
end

--[[
This is used by the context to manage the group.
:param matcher: Entity
]]
function M:handle_entity(entity)
    if not self._matcher:match_entity(entity) then
        if not self:_remove_entity_silently(entity) then
            return
        end
        return self.on_entity_removed
    end
    if not self:_add_entity_silently(entity) then
        return
    end
    return self.on_entity_added
    --if self._matcher:match_entity(entity) then
    --    self:_add_entity(entity, comp_value)
    --else
    --    self:_remove_entity(entity, comp_value)
    --end
end

--[[
This is used by the context to manage the group.
:param matcher: Entity
]]
function M:update_entity(entity, comp_value)
    if set.has(self.entities, entity) then
        self.on_entity_removed(entity, comp_value)
        self.on_entity_added(entity, comp_value)
        self.on_entity_updated(entity, comp_value)
    end
end

function M:_add_entity_silently(entity)
    return set_insert(self.entities, entity)
end

function M:_add_entity(entity, comp_value)
    local entity_added = self:_add_entity_silently(entity)
    if entity_added then
        --print(self,"add_entity",entity)
        self.on_entity_added(entity, comp_value)
    end
end

function M:_remove_entity_silently(entity)
    return set_remove(self.entities, entity)
end

function M:_remove_entity(entity, comp_value)
    local entity_removed = self:_remove_entity_silently(entity)
    if entity_removed then
        self.on_entity_removed(entity, comp_value)
    end
end

return M
