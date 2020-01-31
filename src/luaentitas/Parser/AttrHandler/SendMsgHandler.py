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
        context.add_custom_inc("require('.{0}')".format(str( context.name.Name + comp.name.Name + 'SendEventSystem')))

    @staticmethod
    def parse_attr(attr:AttrEntity):
        data = attr.dates.value
        attr.replaceEventType(data)
        ret_str = ""
        if attr.eventType.value == 'ADDED':
            ret_str = 'GroupEvent.ADDED'
        elif attr.eventType.value == "REMOVED":
            ret_str = 'GroupEvent.REMOVED'
        elif attr.eventType.value == "ALL":
            ret_str = 'GroupEvent.ADDED | GroupEvent.REMOVED'
        attr.replaceEventTypeGroupStr(ret_str)

    def generate_event_name(self, attrs):
        # todo: 生成消息
        return

    def start_handle(self):
        for attr in self.attrs:
            self.render_mako(attr, self.context)
        self.generate_event_name(self.attrs)
