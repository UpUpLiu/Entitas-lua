import os

from mako.template import Template

import utils
from pythonentitas.Generated.Entitas.AttrEntity import AttrEntity
from .BaseAttrHandler import BaseAttrHandler



class SendMsgHandler(BaseAttrHandler):
    def __init__(self, attr_define):
        super().__init__( attr_define)
        return

    def template_render(self, template, attr,  context):
        return template.render(
            _context= context,
            _attrs = self.attrs,
            _attr = attr
        )

    def get_out_file_name(self):
        return self.attr_define.Key

    def render_mako(self, attr : AttrEntity, context):
        comp = attr.component.value
        file_path = os.path.join(self.context.outPut.value,  context.name.Name + comp.name.Name + 'SendEventSystem.lua')
        file = utils.open_file(file_path, 'w')
        template = Template(filename=str(self.mako_path),
                            module_directory=os.path.join(self.script_path, 'makoCache'))
        content = self.template_render(template, attr, context)
        content = content.replace('\n', '')
        content = content.replace('\r\n', '')
        file.write(content)
        file.close()

    def start_handle(self):
        for attr in self.attrs:
            self.render_mako(attr, self.context)
