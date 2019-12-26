local set           = require("Common.container.set")
local GroupEvent    = import(".GroupEvent")
local set_insert    = set.insert
local set_remove    = set.remove

local M  = {}
M.__index = M

function M.new(groups)
    local tb = {}
    tb.entities = set.new(true)
    tb._groups = groups
    tb = setmetatable(tb, M)
    tb.activate(tb)
    return tb
end

--Activates the Collector and will start collecting
--changed entities. Collectors are activated by default.
function M:activate()
    ---@param group entitas.Group
    for group, group_event in pairs(self._groups) do
        if 0 ~= (group_event & GroupEvent.ADDED) and not group.on_entity_added:has(self._add_entity) then
            group.on_entity_added:add(self._add_entity, self)
        end

        if 0 ~= (group_event & GroupEvent.REMOVED) and not group.on_entity_removed:has(self._remove_entity) then
            group.on_entity_removed:add(self._remove_entity, self)
        end

        if 0 ~= (group_event & GroupEvent.UPDATE) and not group.on_entity_updated:has(self._add_entity) then
            group.on_entity_updated:add(self._add_entity, self)
        end
    end
end

function M:deactivate()
    for group, _ in pairs(self._groups) do
        group.on_entity_added:remove(self._add_entity)
        group.on_entity_removed:remove(self._remove_entity)
        group.on_entity_updated:remove(self._add_entity)
    end

    self:clear_entities()
end

function M:clear_entities()
    self.entities:clear()
end

function M:_add_entity(entity)
    -- if self.entities:has(entity) then
    --     assert(false,string.format( "Collect already has Entity %s",tostring(entity)))
    -- end
    set_insert(self.entities, entity)
end

function M:_remove_entity(entity)
    -- if not self.entities:has(entity) then
    --     for group, et in pairs(self._groups) do
    --         print(group,et)
    --     end
    --     assert(false,string.format( "Collect has not Entity %s",tostring(entity)))
    -- end
    set_remove(self.entities, entity)
end

return M
