from ...entitas.MakeComponents import namedtuple
<%
    Context_name = context_name[0].upper() + context_name[1:]
    def params_str(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append('' + item[0] + '')
        return sep.join(b)
    components = contexts.components
%>\
class ${Context_name}Components:
%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
    %if not comp.simple:

    class ${Name}:
        _name = '${name}'
        _Name = '${Name}'

        def __init__(self, ${params_str(properties)}):
            %for p in properties:
            self.${p[0]} = ${p[0]}
            %endfor
    %else:

    class ${Name}:
        _name = '${name}'
        _Name = '${Name}'
    %endif
%endfor

