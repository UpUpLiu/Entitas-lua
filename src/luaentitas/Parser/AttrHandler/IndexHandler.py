import os
from pathlib import Path

from mako.template import Template

import utils
from .BaseAttrHandler import BaseAttrHandler



class IndexHandler(BaseAttrHandler):
    script_path = Path("")

    def __init__(self, attr_define):
        super().__init__( attr_define)
        return


    def template_render(self, template, context):
        return template.render(
            _context= context,
            _attrs = self.attrs
        )


    def get_out_file_name(self):
        return self.attr_define.Key

    def render_mako(self, fime_name,  context):
        file_path = os.path.join(self.context.outPut.value,  context.name.Name + fime_name + '.lua')
        file = utils.open_file(file_path, 'w')
        template = Template(filename=str(self.mako_path),
                            module_directory=os.path.join(self.script_path, 'makoCache'))
        content = self.template_render(template, context)
        content = content.replace('\n', '')
        content = content.replace('\r\n', '')
        file.write(content)
        file.close()

    def start_handle(self):
        self.render_mako(self.get_out_file_name(), self.context)
        return
