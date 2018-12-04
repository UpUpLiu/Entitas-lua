local GroupEventType = require("entitas.GroupEventType")
---@class GroupObserver
local GroupObserver = {}
GroupObserver.__index = GroupObserver
function GroupObserver.new(...)
    local tb = setmetatable({}, GroupObserver)
    tb:ctor(...)
    return tb
end

function GroupObserver:ctor(groups, eventTypes)
    if type(groups) == "table" and #groups >= 1 then
        self._groups = groups
    else
        self._groups = {groups}
    end

    if type(eventTypes) == "table" then
        self._eventTypes = eventTypes
    else
        self._eventTypes = {eventTypes}
    end
    if #self._groups ~= #self._eventTypes then
        --error("Unbalanced count with groups (" .. tostring(#self._groups ) ..
        --        ") and event types (" .. tostring(#self._eventTypes ).. ")")
        print(#self._groups, #self._eventTypes)
        error("Unbalanced count with groups and event types ")
    end
    self._collectedEntities = {}
    self._addEntityCache = function(...) self:addEntity(...) end
    self:activate()
end

function GroupObserver:activate()

    local len = #self._groups
    for i = 1, len do
        local group = self._groups[i]
        local eventType = self._eventTypes[i]

        if (eventType == GroupEventType.OnEntityAdded) then
            group.onEntityAdded:remove(self._addEntityCache)
            group.onEntityAdded:add(self._addEntityCache)
        elseif (eventType == GroupEventType.OnEntityRemoved) then
            group.onEntityRemoved:remove(self._addEntityCache)
            group.onEntityRemoved:add(self._addEntityCache)
        elseif (eventType == GroupEventType.OnEntityAddedOrRemoved) then
            group.onEntityAdded:remove(self._addEntityCache)
            group.onEntityAdded:add(self._addEntityCache)
            group.onEntityRemoved:remove(self._addEntityCache)
            group.onEntityRemoved:add(self._addEntityCache)
        else
            --throw `Invalid eventType [${typeof eventType}:${eventType}] in GroupObserver.lua::activate`
        end
    end
end

function GroupObserver:deactivate()
    local len = #self._groups
    for i = 0, len do
        local group = self._groups[i]
        group.onEntityAdded.remove(self._addEntityCache)
        group.onEntityRemoved.remove(self._addEntityCache)
        self.clearCollectedEntities()
    end
end

function GroupObserver:clearCollectedEntities()
    for i, v in pairs(self._collectedEntities) do
        v:release()
    end
    self._collectedEntities = {}
end

function GroupObserver:addEntity(group, entity, index, component)
    if not self._collectedEntities[entity.id] then
        self._collectedEntities[entity.id] = entity
        entity:addRef()
    end
end

function GroupObserver:collectedEntities()
    return self._collectedEntities
end

return GroupObserver