require("Common.base.import")
require("Common.entitas.entitas")

%for key in contexts:
<%
    Context_name = contexts[key].Name
%>\
class(import(".${Context_name}Entity"),'${Context_name}Entity',classMap.Entity)
class(import(".${Context_name}Matchers"),'${Context_name}Matchers',classMap.Matchers)
class(import(".${Context_name}Components"),'${Context_name}Components',classMap.Components)
class(import(".${Context_name}Context"),'${Context_name}Context',classMap.Context)
%endfor
---@class Contexts
%for key in contexts:
<%
    Context_name = contexts[key].name
    name = contexts[key].name
%>\
---@field ${name} ${Context_name}Context
%endfor
local Contexts
return function()
    Contexts = {}
%for key in contexts:
<%
    Context_name = contexts[key].Name
%>\
    Contexts.${contexts[key].Name} = import(".${Context_name}Context"):new(import(".${Context_name}Entity"))
%endfor
    return Contexts
end







