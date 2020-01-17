<%
    comp = _attr.component.value
    Name = comp.name.Name
    name =  comp.name.name
    attr_name = _attr.name.value
    source = _context.source.value
    Context_name = _context.name.Name
    context_name = _context.name.name
%>\
local Matcher = require("${source}.Matcher")
local GroupEvent = require("${source}.GroupEvent")
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
            Matcher({${Context_name}_comps.${Name}}),
            ${_attr.get_group_event_out_str()}
        }
    }
end

function M:filter(entity)
    return entity:has${Name}()
end

function M:execute(es)
    es:foreach( function( e  )
%if comp.hasIsSimple():
        EntitasEvent.${Context_name}:DispatchEvent(EntitasEventConst.${Context_name}.${name}, e)
%else:
        local comp = e.${Name}
        EntitasEvent.${Context_name}:DispatchEvent(EntitasEventConst.${Context_name}.${name}, e)
%endif
    end)
end

return M
