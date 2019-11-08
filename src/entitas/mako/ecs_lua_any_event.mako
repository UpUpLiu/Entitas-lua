<%
    Name = component.Name
    name =  component.name
    comp = component
    Context_name = context_name[0].upper() + context_name[1:]
    properties = component.data
%>\
local Matcher = require("${contexts.source}.Matcher")
local GroupEvent = require("${contexts.source}.GroupEvent")
local ${Context_name}_comps = require('.${context_name}Components')
local ${Context_name}Matcher = require('.${context_name}Matchers')
local utils = require("Common.utils")

---@class ${Name}EventSystem : entitas.ReactiveSystem
local M = class({},'${Name}EventSystem', classMap.ReactiveSystem)

function M:Ctor(context)
    M.__super.Ctor(self, context)
    self._listeners = context:get_group(${Context_name}Matcher.${Name})
end

function M:get_trigger()
    return {
        {
            Matcher({${Context_name}_comps.${comp.event_target.Name}}),
            GroupEvent.${event.get_group_event()} | GroupEvent.UPDATE
        }
    }
end

function M:filter(entity)
    return entity:has${comp.event_target.Name}()
end

function M:execute(es)
    local buffer = self._listeners:get_entity_buffer()
    es:foreach( function( e  )
        local comp = e.${comp.event_target.name}
        for _, entity in pairs(buffer) do
            local list = utils.CopyTable(entity.${name}.value:get_buffer())
            for i = 1, #list do
                list[i]:On${Name}(e ${comp.get_func_params('comp.')} );
            end
        end
    end)
end

return M
