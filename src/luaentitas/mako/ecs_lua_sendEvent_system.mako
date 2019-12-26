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
local tabledeepcopy = table.deepcopy
---@class ${Name}SendEventSystem : entitas.ReactiveSystem
local M = class({},'${Name}SendEventSystem', classMap.ReactiveSystem)

function M:Ctor(context)
    M.__base.Ctor(self, context)
end

function M:get_trigger()
    return {
        {
            Matcher({${Context_name}_comps.${comp.event_target.Name}}),
            ${event.get_group_event()}
        }
    }
end

function M:filter(entity)
%if comp.event_target == 'self':
    return entity:has${comp.event_target.Name}() and entity:has${comp.event_target.Name}()
%else:
    return entity:has${comp.event_target.Name}()
%endif
end

function M:execute(es)
    es:foreach( function( e  )
%if comp.is_empty():
        EntitasEvent.${Context_name}:DispatchEvent(EntitasEventConst.${Context_name}.${name}, e)
%else:
        local comp = e.${comp.event_target.name}
        EntitasEvent.${Context_name}:DispatchEvent(EntitasEventConst.${Context_name}.${name}, e ${comp.get_func_params('comp.')})
%endif
    end)
end

return M
