import os

from mako.template import Template

import utils
from pythonentitas import AttrEntity
from .BaseAttrHandler import BaseAttrHandler


class EventHandler(BaseAttrHandler):
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
        file_path = os.path.join(self.context.outPut.value,  context.name.Name + attr.generateCompName.Name + 'EventSystem.lua')
        file = utils.open_file(file_path, 'w')
        template = Template(filename=str(self.mako_path),
                            module_directory=os.path.join(self.script_path, 'makoCache'))
        content = self.template_render(template, attr, context)
        content = content.replace('\n', '')
        content = content.replace('\r\n', '')
        file.write(content)
        file.close()
        context.add_custom_inc("require('.{0}')".format(str( context.name.Name + comp.name.Name + 'SendEventSystem')))

    def start_handle(self):
        for attr in self.attrs:
            self.parse_attr(attr)
            self.render_mako(attr, self.context)


    @staticmethod
    def parse_attr(attr : AttrEntity):
        comp = attr.component.value
        data = attr.dates.value
        assert data.eventType, "event must has eventType, compName:" + comp.name.name
        e_type = data.eventType.lower()
        attr.replaceEventType(e_type[0].upper() + e_type[1:])
        assert data.eventTarget, "event must has eventTarget"
        e_type = data.eventTarget.lower()
        attr.replaceEventTarget(e_type[0].upper() + e_type[1:])
        attr.replaceGenerateCompName(attr.eventTarget.value[0].upper() + attr.eventTarget.value[1:] + attr.eventType.value + comp.name.Name,
                                     attr.eventTarget.value[0].lower() + attr.eventTarget.value[1:] + attr.eventType.value + comp.name.Name)
        ret_str = ""
        if data.eventType == 'ADDED':
            ret_str = 'GroupEvent.ADDED'
        elif data.eventType == "REMOVED":
            ret_str = 'GroupEvent.REMOVED'
        elif data.eventType == "ALL":
            ret_str = 'GroupEvent.ADDED | GroupEvent.REMOVED'
        attr.replaceEventTypeGroupStr(ret_str)

        return
