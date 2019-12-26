require("Common.base.import")
require("Common.entitas.entitas")
Components = {}
%for key in contexts:
<%
    Context_name = contexts[key].Name
%>\
class(import(".${Context_name}Entity"),'${Context_name}Entity',classMap.Entity)
class(import(".${Context_name}Matchers"),'${Context_name}Matchers',classMap.Matchers)
Components.${Context_name} = require(".${Context_name}Components")
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
    Contexts.${contexts[key].Name} = classMap.${Context_name}Context:new(classMap.${Context_name}Entity)
    Contexts.${contexts[key].Name}:initGenerateEntityIndexes()
%endfor
    return Contexts
end







