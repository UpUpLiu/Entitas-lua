local make_component = require("${source_path}.MakeComponent")
local Components = {}
<%
    def params_str(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append('"' + item[0] + '"')
        return sep.join(b)
    components = contexts.components
%>\
%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
    %if not comp.simple:
---@class ${Context_name}.${Name}Component
        %for i in range(len(properties)):
---@field ${properties[i][0]} ${comp.get_property(i, contexts)}
        %endfor
Components.${Name} = make_component('${name}',  ${params_str(properties)})
    %else:
---@class ${Context_name}.${Name}Component
Components.${Name} = make_component('${name}')
    %endif
%endfor

return Components