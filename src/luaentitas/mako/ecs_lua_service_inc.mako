<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts.components
%>\
---@type ${contexts.simple_name}Service
Service.${contexts.simple_name} = import(".${contexts.simple_name}Service")
Service.${contexts.simple_name}.init()