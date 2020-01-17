require("Common.base.import")
require("Common.entitas.entitas")
Components = {}
%for key in contexts:
<%
    _context = contexts[key]
    Context_name = contexts[key].name.Name
%>\
class(require(".${Context_name}Entity"),'${Context_name}Entity',classMap.Entity)
class(require(".${Context_name}Matchers"),'${Context_name}Matchers',classMap.Matchers)
Components.${Context_name} = require(".${Context_name}Components")
class(require(".${Context_name}Context"),'${Context_name}Context',classMap.Context)
%if _context.hasCustomInc():
    %for custom in _context.customInc.value:
${custom}
    %endfor
%endif

%endfor
---@class Contexts
%for key in contexts:
<%
    Context_name = contexts[key].name.Name
    name = contexts[key].name.name
%>\
---@field ${name} ${Context_name}Context
%endfor
local Contexts
return function()
    Contexts = {}
%for key in contexts:
<%
    Context_name = contexts[key].name.Name
    name = contexts[key].name.name
%>\
    Contexts.${Context_name} = classMap.${Context_name}Context:new(classMap.${Context_name}Entity)
    Contexts.${Context_name}:initGenerateEntityIndexes()
%endfor
    return Contexts
end







