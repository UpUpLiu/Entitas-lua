<%
    Context_name = _context.name.Name
    components = _context.components.value
    source_path = _context.source.value
%>
local make_component = require("${source_path}.MakeComponent")
local Components = {}

%for comp in components:
<%
    Name = comp.name.Name
    name =  comp.name.name
    properties = comp.get_properties()
%>\
    %if not comp.hasIsSimple():
---@class ${Context_name}.${Name}Component
Components.${Name} = make_component('${name}')
    %else:
---@class ${Context_name}.${Name}Component
${comp.get_properties_define()}
Components.${Name} = make_component('${name}',  ${comp.get_params_str()})
    %endif
%endfor

return Components