<%
    Context_name = context_name[0].upper() + context_name[1:]
    components = contexts.components
    event_comps = contexts.event_comps
    import json
    def params(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append(item[0])
        return sep.join(b)

    def params_str(a, sep = ', ' , b = []):
        b = []
        for item in a:
            b.append('"' + item[0] + '"')
        return sep.join(b)
%>\

from ...entitas import Context, Entity, PrimaryEntityIndex, EntityIndex, Matcher
from .${Context_name}Components import ${Context_name}Components as ${Context_name}_comps


class ${Context_name}Entity(Entity):
    def __init__(self):
        super().__init__()
% for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>\
        self.${name} = None
% endfor
        return


%for comp in components:
<%
    Name = comp.Name
    name =  comp.name
    Context_name = context_name[0].upper() + context_name[1:]
    properties = comp.data
%>
    %if not comp.simple:
    def has${Name}(self):
        return self.has(${Context_name}_comps.${Name})

    def add${Name} (self, ${params(properties)}):
        self.add(${Context_name}_comps.${Name}, ${params(properties)})
        return self

    def replace${Name} (self,${params(properties)}):
        self.replace(${Context_name}_comps.${Name}, ${params(properties)})
        return self

    def remove${Name} (self):
        self.remove(${Context_name}_comps.${Name})
        return self
        %else:
    def has${Name}(self):
        return self.has(${Context_name}_comps.${Name})

    def set${Name}(self, v):
        if (v != self.has${Name}()):
            if (v):
                self.add(${Context_name}_comps.${Name})
            else:
                self.remove(${Context_name}_comps.${Name})
        return self
        %endif
    %endfor
    %if event_comps:
        %for comp in event_comps:
    def Add${comp.Name}CallBack(self, callback, target):
        local list
        if not self.has${comp.Name}() then
            list = set.new(false)
        else
            list = self.${comp.name}.value
        end
        list:insertkv(callback, target)
        self.replace${comp.Name}(list)

    def Remove${comp.Name}CallBack(self, callback, removeComponentWhenEmpty):
        if removeComponentWhenEmpty == nil then
            removeComponentWhenEmpty = true
        end
        local listeners = self.${comp.name}.value
        listeners:remove(callback)
        if removeComponentWhenEmpty and listeners:size() == 0 then
            self.remove${comp.Name}()
        else
            self.replace${comp.Name}(listeners)
        end
        %endfor
    %endif

