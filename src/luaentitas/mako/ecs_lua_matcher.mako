<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts.components
%>\
local ${Context_name}_comps = require('.${context_name}Components')
local Matcher = require('${source_path}.Matcher')
----------------------------Matcher     start-------------------------------------------
---@class ${Context_name}Matcher
%for comp in components:
<%
    Name = comp.name
    Name = Name[0].upper() + Name[1:]
%>\
---@field ${Name}  entitas.Matcher
%endfor
local ${Context_name}Matcher = {}
%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
    %>\
${Context_name}Matcher.${Name} = Matcher({${Context_name}_comps.${Name}})
%endfor
----------------------------Matcher     end---------------------------------------------
return ${Context_name}Matcher