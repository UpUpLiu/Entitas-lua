import json
import os
from mako.template import Template
from pathlib import Path
import src.utils as utils
import build_config
import collections
import importlib

from luaentitas.Parser.AttrHandler import BaseAttrHandler
from pythonentitas.Generated.Entitas.AttrEntity import AttrEntity
from pythonentitas.Generated.Entitas.ContextEntity import ContextEntity

CLIENT_LUA_PROJECT_ROOT = Path( build_config.CLIENT_LUA_PROJECT_ROOT)
import operator

class KV:
    def __init__(self):
        self.k = None
        self.v = None

class AttrClass():
    def __init__(self):
        self.class_name = str.lower(self.__class__.__name__)
        self.on_init()
    def on_init(self):
        return

class PrimaryIndex(AttrClass):
    def on_init(self):
        return

class Index(AttrClass):
    def on_init(self):
        return

class MuIndex(AttrClass):
    def on_init(self):
        self.index_data = []
        self.funcName = ""
        return
    
    def addData(self, comp_name, comp_value):
        temp_t = KV()
        temp_t.k = comp_name
        temp_t.v = comp_value
        self.index_data.append(temp_t)
        return

    def setFuncName(self, name):
        self.funcName = name

class Event(AttrClass):
    def __init__(self):
        super().__init__()
        self.event = None
        self.target = None
        self.type = None
        self.priority = 0
        self.action = None

    def on_init(self):
        self.event = None
        return

    def init_event(self, event):
        self.event = event
        self.target = event.target
        self.type = event.type or 'ADDED'
        self.priority = event.priority or 0
        self.action = event.action

    def get_group_event(self):
        if self.type != "ALL":
            return "GroupEvent."+self.type
        else:
            return "GroupEvent.ADDED | GroupEvent.REMOVED"

class Component():
    def __init__(self, name):
        self.data = []
        self.single = False
        self.attr = []
        self.simple = True
        self.name = name[0].lower() + name[1:]
        self.tag = None
        self.has_attr = False
        self.Name = name[0].upper() + name[1:]
        self.event_target = None
        self.event_action = None
        self.event = []
        return

    def __cmp__(self, other):
        if self.name > other.name:
            return 1
        else:
            return -1

    def is_empty(self):
        return len(self.data) == 0

    def set_data(self, data):
        self.data = []
        self.simple = False
        for i in range(len(data)):
            p = data[i]
            sp_ret = p.split('@')
            self.parse_property_data(i, sp_ret[0])
            if len(sp_ret) > 1:
                sp_ret = sp_ret[1].split('|')
                for prop in sp_ret:
                    prop = prop.replace(' ','')
                    self.parse_property_data_attr(prop, self.data[i][0])

    def parse_property_data(self, i, property):
        sp_ret = property.split(':')
        self.data.append([0, 0])
        self.data[i][0] = sp_ret[0].replace(' ', '')
        self.data[i][1] = sp_ret[1]
        return

    def parse_property_data_attr(self, attr, p_name):
        if attr == 'primaryIndex':
            temp = PrimaryIndex()
            temp.p_name = p_name
            self.attr.append(temp)
        elif attr == 'index':
            temp = Index()
            temp.p_name = p_name
            self.attr.append(temp)
        return

    def get_property(self, i, context):
        ret_str = self.data[i][1]
        if context.pre_tag:
            ret_str = ret_str.replace('${pre_tag}', context.pre_tag).replace(' ', '')
        return ret_str

    def set_single(self, single):
        self.single = single

    def set_event(self, events):
        for index in events:
            event = events[index]
            if not event.target:
                raise ("event must has target")
            e = Event()
            e.init_event(event)
            self.event.append(e)

    def add_attr(self, key, val):
        self.attr[key] = self['parser_attr'+ key](val)

    def parser_attr_primaryIndex(self, attr):
        for at in attr:
            name =  at.split(':')
            name.replace(' ', '')
            is_have = False
            for data in self.data:
                if data[0] == name:
                    is_have = True
                    break
            if not is_have:
                raise (' attr value not in comp')

    def parser_attr_Index(self, attr):
        for at in attr:
            name = at.split(':')
            name.replace(' ', '')
            is_have = False
            for data in self.data:
                if data[0] == name:
                    is_have = True
                    break
            if not is_have:
                raise (' attr value not in comp')

    def parser_attr_Event(self, attr):
        for at in attr:
            name = at.split(':')
            name.replace(' ', '')
            is_have = False
            for data in self.data:
                if data[0] == name:
                    is_have = True
                    break
            if not is_have:
                raise (' attr value not in comp')

        return attr

    def get_func_params(self, pre = '', sep = ', '):
        b = []


        for item in self.data:
            b.append(pre + item[0])
        if len(self.data) > 0:
            return ', ' +sep.join(b)
        return ''


    def set_tag(self, tags):
        self.tag = tags

    def add_event(self, event):
        if event.eventTarget is None:
            raise ("error")
        self.event.append(event)

class ContextData():
    def __init__(self, tag):
        self.components = []
        self.event_comps = []
        self.source = ""
        self.name = tag
        self.Name = tag[0].upper() + tag[1:]
        self.muIndex = []
        self.tag = tag
        self.pre_tag = ""
        self.simple_name = tag
        if '_' in self.tag:
            self.pre_tag = self.tag[0:2]
            self.simple_name = self.simple_name.replace(self.pre_tag, '')


    def setSource(self, source):
        self.source = source

    def setOutPut(self, output):
        self.output = output

    def setComponents(self, comps):
        self.components = comps

    def addComponent(self, comp):
        self.components.append(comp)

    def addEventComponent(self, comp):
        self.event_comps.append(comp)

    def check(self):
        for comp in self.components:
            if comp.tag is None:
                raise (comp.name + "tag is None")

    def addContextMuIndex(self, index):
        self.muIndex.append(index)
        return

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

    def generate_event(self):
        for key, context in self.contexts.items():
            comps = context.components
            for comp in comps:
                for event in comp.event:
                    if not event.type:
                        event.type = 'Added'

                    temp_name = comp.Name + event.type + 'Listener'

                    if event.target == 'Any':
                        temp_name = 'Any' + temp_name
                    event_comp = Component(temp_name)
                    if not event.action:
                        event_comp.set_data(['value : callback[]'])
                    event_comp.event_target = comp
                    if event.action:
                        comp.event_action = event.action
                    context.addEventComponent(event_comp)
                    context.addComponent(event_comp)
                    mako_file = ""
                    if event.action:
                        file_name = os.path.join(self.outpath, event_comp.Name + "SendEventSystem.lua")
                        mako_file = "ecs_lua_sendEvent_system.mako"
                    else:
                        file_name = os.path.join(self.outpath, event_comp.Name + "EventSystem.lua")
                        mako_file = "ecs_lua_"+ event.target +"_event.mako"
                    file = utils.open_file(file_name, 'w')
                    template = Template(filename=str(self.mako_path / mako_file),
                                        module_directory=os.path.join(self.scirpt_path, 'makoCache'))
                    content = template.render(
                        context_name=context.name,
                        contexts=context,
                        source_path=self.source,
                        component = event_comp,
                        event = event)
                    file.write(content.replace('\n', ''))
        self.after_generate_event()

    def after_generate_event(self):
        self.generate_reactive_system()
        # self.generate_send_event_system()
        # self.generate_auto_send_event()
        return

    # def generate_auto_send_event(self):
    #     event_file = os.path.join(self.outpath, 'EntitasEventAutoInc.lua')
    #     file = utils.open_file(event_file, 'w')
    #     template = Template(filename=str(self.mako_path / ("ecs_lua_event_name.mako")),
    #                         module_directory=os.path.join(self.scirpt_path, 'makoCache'))
    #     content = template.render(
    #         contexts=self.contexts,
    #         source_path=self.source,
    #     )
    #     file.write(content.replace('\n', ''))

    def generate_reactive_system(self):
        for key, context in self.contexts.items():
            if not context.event_comps:
                continue
            temp_name = context.name + 'EventSystems'
            file_name = os.path.join(self.outpath, temp_name + ".lua")
            file = utils.open_file(file_name, 'w')
            template = Template(filename=str(self.mako_path / ("ecs_lua_event_inc.mako")),
                                module_directory=os.path.join(self.scirpt_path, 'makoCache'))
            content = template.render(
                context_name=context.name,
                contexts=context,
                source_path=self.source,
                components=context.event_comps,
            )
            file.write(content.replace('\n', ''))

        return

    def generate_send_event_system(self):
        for key, context in self.contexts.items():
            if not context.event_comps:
                continue
            temp_name = context.name + 'EventSystems'
            file_name = os.path.join(self.outpath, temp_name + ".lua")
            file = utils.open_file(file_name, 'w')
            template = Template(filename=str(self.mako_path / ("ecs_lua_sendEvent_system.mako")),
                                module_directory=os.path.join(self.scirpt_path, 'makoCache'))
            content = template.render(
                context_name=context.name,
                contexts=context,
                source_path=self.source,
                components=context.event_comps,
            )
            file.write(content.replace('\n', ''))
        return

    def generate_context_index(self):
        for key, context in self.contexts.items():
            if not context.event_comps:
                continue
            temp_name = context.name + 'EventSystems'
            file_name = os.path.join(self.outpath, temp_name + ".lua")
            file = utils.open_file(file_name, 'w')
            template = Template(filename=str(self.mako_path / ("ecs_lua_event_in.mako")),
                                module_directory=os.path.join(self.scirpt_path, 'makoCache'))
            content = template.render(
                context_name=context.name,
                contexts=context,
                source_path=self.source,
                components=context.event_comps,
            )
            file.write(content.replace('\n', ''))

        return

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
        self.generate_autoinc()
        # self.generate_auto_service_inc()

        self.generate_attrs()
