import json
import os
from mako.template import Template
from pathlib import Path
import src.utils as utils
import build_config
import collections
import importlib

from luaentitas.Parser.AttrHandler import BaseAttrHandler
from pythonentitas import AttrEntity
from pythonentitas import ContextEntity

CLIENT_LUA_PROJECT_ROOT = Path( build_config.CLIENT_LUA_PROJECT_ROOT)
import operator

class AttrDefine:
    attrList = None
    def __init__(self, key, data):
        if data.attrList:
            self.attrList = set()
            for index in data.attrList:
                self.attrList.add(data.attrList[index])
        else:
            self.attrList = {key}
        self.handleTogether = False
        self.key = key
        self.Key = key[0].upper() + key[1:]
        if data.handleTogether:
            self.handleTogether = True
        return

    def hand_attr(self, attr):
        if self.attrList[attr] is None:
            return
        print("处理attr")
        return

class BaseParser:
    parser_tag = ""
    contexts = {}
    config_path = ""
    scirpt_path = ""
    mako_path = ""
    base_config_file = ""
    source = ""
    output = ""
    namespace = ""
    attrDefine = None
    file_suffix = ""
    def __init__(self):
        self.source =""
        self.namespace = ""
        self.outpath = ""
        self.attrDefine = []  # type: list[AttrDefine]
        self.contexts = collections.OrderedDict()
        self.service_path = Path("")
        self.mako_path = self.scirpt_path / '../mako'
        self.context_index_path = self.config_path / "ContextIndex.lua"
        self.base_config_file = self.config_path / ("entitas.json")
        self.on_init()
        self.load_base_config()
        self.load_context_config()

    def add_attr_define(self, key, attr_define):
        attr = AttrDefine(key, attr_define)
        self.attrDefine.append(attr)
        return

    def load_base_config(self):
        return


    def load_context_config(self):
        return


    def on_init(self):
        return

    def get_files_by_path(self):
        return

    def render_mako(self, fime_name, mako_name, context):
        file_path = os.path.join(self.outpath,  context.name.Name + fime_name)
        file = utils.open_file(file_path, 'w')
        template = Template(filename=str(self.mako_path / mako_name),
                            module_directory=os.path.join(self.scirpt_path, 'makoCache'))
        content = self.template_render(template, context)
        content = content.replace('\n', '')
        content = content.replace('\r\n', '')
        file.write(content)
        file.close()

    def template_render(self, template, context):
        return template.render(
            _context = context
        )

    def generate_context(self):
        for key, context in self.contexts.items():
            self.render_mako("Context" + self.file_suffix,'ecs_lua_context.mako', context)

    def generate_entity(self):
        for key, context in self.contexts.items():
            self.render_mako("Entity"+ self.file_suffix,'ecs_lua_entity.mako', context)

    def generate_component(self):
        for key, context in self.contexts.items():
            self.render_mako("Components"+ self.file_suffix,'ecs_lua_make_component.mako', context)

    def generate_autoinc(self):
        template = Template(filename=str(self.mako_path / "ecs_lua_autoinc.mako"),
                            module_directory=os.path.join(self.scirpt_path, 'makoCache'))
        file_name = os.path.join(self.outpath, "EntitasAutoInc.lua")
        file = utils.open_file(file_name, 'w')
        content = template.render(
            contexts = self.contexts,
            source_path = self.source
        )
        content = content.replace('\n', '')
        content = content.replace('\r\n', '')
        file.write(content)
        file.close()

    def generate_auto_service(self, context):
        script_path = self.service_path / 'Service'
        file_name = script_path / (context.simple_name + 'Service.lua')
        if not os.path.exists(file_name):
            temp_file = utils.open_file(file_name , 'w')
            template = Template(filename=str(self.mako_path / "ecs_lua_service.mako"),
                                 module_directory=os.path.join(self.scirpt_path, 'makoCache'))
            content = template.render(
                context_name=context.simple_name,
                contexts= context,
                source_path= self.source)
            content = content.replace('\n', '')
            content = content.replace('\r\n', '')
            temp_file.write(content)

    def generate_auto_service_inc(self):
        script_path = self.service_path / 'Service'
        template = Template(filename=str(self.mako_path / "ecs_lua_service_Inc.mako"),
                            module_directory=os.path.join(self.scirpt_path, 'makoCache'))
        file_name = os.path.join(script_path, "EntitasAutoServiceInc.lua")
        file = utils.open_file(file_name, 'w')
        file.write('Service = {}\n')
        for key, context in self.contexts.items():
            content = self.template_render(template, context)
            self.generate_auto_service(context)
            content = content.replace('\n', '')
            content = content.replace('\r\n', '')
            file.write(content)

        file.close()

    def get_attr_by_define(self, attr_define, context : ContextEntity):
        comps = context.components.value
        ret = []
        # print(len(comps))
        for comp in comps:
            if comp.hasAttrs():
                attrs = comp.attrs.value # type:list[AttrEntity]
                for attr in attrs:
                    name = attr.name.value.replace(' ', '')
                    if name in attr_define.attrList:
                        ret.append(attr)

        return ret

    def generate_attrs(self):
        for attr in self.attrDefine:
            for key, context in self.contexts.items():
                attrs = self.get_attr_by_define(attr, context)
                path = "src.luaentitas.Parser.AttrHandler.{0}Handler.{0}Handler".format(attr.Key)
                model_path, class_name = path.rsplit(".", 1)
                model = importlib.import_module(model_path)  # 根据"auth.my_auth"导入my_auth模块
                obj: BaseAttrHandler = getattr(model, class_name)(attr)
                obj.set_contexts(context)
                obj.set_attrs(attrs)
                obj.start_handle()



    def before_generate(self):
        for key, context in self.contexts.items():
            cmpfun = operator.attrgetter('name.name')
            context.components.value.sort(key = cmpfun)
            # context.event_comps.value.sort(key = cmpfun)
        return

    def generate(self):
        self.before_generate()
        self.generate_context()
        self.generate_component()
        self.generate_entity()
        # self.generate_auto_service_inc()

        self.generate_attrs()
        self.generate_autoinc()

