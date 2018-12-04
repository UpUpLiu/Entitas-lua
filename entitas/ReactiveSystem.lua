local utils = require("entitas.util")
local table_insert = table.insert
local GroupObserver = require("entitas.GroupObserver")

---@class Ecs.ReactiveSystem
local ReactiveSystem  = utils.class("ReactiveSystem")

function ReactiveSystem:initialize()
end

function ReactiveSystem:getTriggers()
    error("not imp")
end

-- function ReactiveSystem:filter()
--     error("not imp")
-- end

function ReactiveSystem:react()
    error("not imp")
end

function ReactiveSystem:ctor(pool)
    self._clearAfterExecute = false
    local triggers = self:getTriggers()
    local triggersLength = #triggers
    ---@type Group[]
    local groups = {}
    local eventTypes = {}
    for i= 1, triggersLength,2 do
        local matcher ,eventType = triggers[i] , triggers[i + 1]
        groups[i] = pool:getGroup(matcher)
        eventTypes[i] = eventType
    end
    self._observer = GroupObserver.new(groups, eventTypes)
    self._buffer = {}
end

function ReactiveSystem:activate()
    self._observer:activate()
end

function ReactiveSystem:deactivate()
    self._observer:deactivate()
end

function ReactiveSystem:clear()
    self._observer:clearCollectedEntities()
end

function ReactiveSystem:execute()
    local collectedEntities = self._observer:collectedEntities()
    local buffer = self._buffer


    if (#utils.keys(collectedEntities) ~= 0) then
        local filter = self.filter
        if filter then
            for _,e in pairs(collectedEntities) do
                if filter(self, e) then
                    table_insert(buffer, e:addRef())
                end
            end
        else
            for _,e in pairs(collectedEntities) do
                table_insert(buffer, e:addRef())
            end
        end

        self._observer:clearCollectedEntities()
        if (#buffer > 0) then
            self:react(buffer)
            local len = #buffer
            for i = 1, len do
                buffer[i]:release()
                buffer[i] = nil
            end
            if (self._clearAfterExecute) then
                self._observer:clearCollectedEntities()
            end
        end
    end
end


return ReactiveSystem