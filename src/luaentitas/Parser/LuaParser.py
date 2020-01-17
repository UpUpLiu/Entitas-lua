# -*- coding: utf-8 -*-
import os
from pathlib import Path

from src.luaentitas.Parser.BaseParser import BaseParser, ContextData, Component, MuIndex
import json
import src.utils as utils
from lupa import *
from src.pythonentitas.Generated.Entitas.Contexts import Contexts
lua = LuaRuntime()

class LuaParser(BaseParser):
    def __init__(self, configPath):
        self.scirpt_path = Path(os.path.split(os.path.realpath(__file__))[0])
        self.config_path = configPath
        self.file_suffix = '.lua'
        super().__init__()


    def on_init(self):
        self.base_config_file = self.config_path / ("entitas.lua")

    def load_context_config(self):
        json_files = utils.get_file_list_with_suffix(self.config_path, '.' + self.parser_tag)
        for file_path in json_files:
            if not file_path.endswith('entitas.lua') and not file_path.endswith('ContextIndex.lua'):
                with open(file_path, 'r', encoding='utf8') as load_f:
                    text = load_f.read()
                    ttt = lua.compile(text)()
                    components = self.get_components(ttt)
                    # print('new comp', len(components))
                    for comp in components:
                        # print('tag',comp.tags.value)
                        for tag in comp.tags.value:
                            # print(comp.tags)
                            # print('add comp', len(components))
                            self.contexts[tag].addComponent(comp)

    def get_components(self, table):
        ret = []
        for key in table:
            ret.append(self.get_component(key, table[key]))
        return ret

    def get_component(self, key, table):
        comp = Contexts.component.create_component(key)
        # print("2",list(table.tag), key , )
        # if table.data:
        #     print('3', list(table.data.values()))
        comp.replaceTags(list(table.tag))
        # print(comp.tags.value)
        if table.data:
            comp.set_component_data(list(table.data.values()))
        else:
            comp.setIsSimple(True)

        if table.single is not None:
            comp.setIsSingle(True)

        comp.replaceTags(list(table.tag.values()))

        if table.event is not None:
            comp.replaceEvents(table.event)

        if table.attr is not None:
            for at in table.attr:
                comp.addAttr(at, table.attr[at])

        return comp

    def parse_context(self, key, table):
        context_files = utils.get_file_list_with_suffix(self.config_path, '.' + self.parser_tag)
        comp = Component(key)
        if table.data:
            comp.set_data(list(table.data.values()))
        if table.single is not None:
            comp.set_single(True)

        comp.set_tag(list(table.tag.values()))
        if table.event is not None:
            comp.set_event(table.event)

        # if table.attr is not None:
        #     for at in table.attr:
        #         comp.add_attr(at, at)
        return comp

    def load_base_config(self):
        with open(self.base_config_file , 'r') as load_f:
            text = load_f.read()
            config = lua.compile(text)()
        self.source = config.source
        self.outpath = self.config_path / config.output
        self.namespace = config.namespace
        self.parser_tag = config.parse
        self.tag = list(config.tag.values())
        self.service_path = self.config_path / Path(config.service_path)
        for key in config.AttrDefine:
            self.add_attr_define(key, config.AttrDefine[key])
        self.tag.sort()
        for tag in self.tag:
            context = Contexts.context.create_entity()
            context.replaceTag(tag)
            context.replaceName(tag[0].lower() + tag[1:], tag[0].upper() + tag[1:])
            context.replaceSource(self.source)
            context.replaceOutPut(self.outpath)
            self.contexts[tag] = context


if __name__ == "__main__":
    LuaParser( Path(utils.get_python_fiel_Path(__file__) + "/../../../EntitasConfig")).generate()
