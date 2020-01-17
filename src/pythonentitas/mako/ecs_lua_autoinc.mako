<%
    print(contexts)
%>
%for k,con in contexts.items():
from ..Extension.Context.${con.Name}Context import ${con.Name}Context
%endfor


class Contexts:
    %for k,con in contexts.items():
<%
            name = con.Name[0].lower() + con.Name[1:]
        %>
    ${name} = ${con.Name}Context()
    %endfor