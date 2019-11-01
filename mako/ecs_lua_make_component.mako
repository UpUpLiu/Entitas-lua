local make_component = require("./MakeComponent")
local Components = {
<%
components = contexts['components']
%>\
%for Name in components:
<%
        name =  Name[0].lower() + Name[1:]
        properties = components[Name]
%>\
    %if components[Name] != False:
    ${Name}Component = make_component('${Name}', '${name}',  ${params_str(properties)}),
    %else:
    ${Name}Component = make_component('${Name}', '${name}'),
    %endif
%endfor
}

return Components