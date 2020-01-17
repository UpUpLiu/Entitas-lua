EntitasEventConst = {}
EntitasEvent = {}

%for key in contexts:
<%
    Context = contexts[key]
    Context_name = Context.name
    name = Context.name
    event_comps = Context.event_comps
%>\
---@class entity.${name}EventConst
local ${Context_name} = {
<%
        index = 0
%>\
    %for event in event_comps:
<%
            index = index + 1
        %>\
    ${event.name } = ${index},
    %endfor
}
EntitasEventConst.${Context_name} = ${Context_name}
EntitasEvent.${Context_name} = require('UI.Base.Event.EventDispatch'):new()
%endfor