# -*- coding: utf-8 -*-
import os
from pathlib import Path

from src.pythonentitas.Parser.BaseParser import BaseParser, ContextData, Component, MuIndex
import json
import src.utils as utils
from lupa import *
from pathlib import Path

lua = LuaRuntime()

class PythonParser(BaseParser):
    def __init__(self, configPath):
        self.scirpt_path = Path(os.path.split(os.path.realpath(__file__))[0])
        self.config_path = configPath
        super().__init__()
        self.file_suffix = '.py'
        return

    def on_init(self):
        self.base_config_file = self.config_path / ("entitas.lua")

    def load_context_config(self):
        json_files = utils.get_file_list_with_suffix(self.config_path, '.' + self.parser_tag)
        for file_path in json_files:
            if not file_path.endswith('entitas.lua'):
                with open(file_path, 'r', encoding='utf8') as load_f:
                    text = load_f.read()
                    ttt = lua.compile(text)()
                    components = self.get_components(ttt)
                    for comp in components:
                        for tag in comp.tag:
                            self.contexts[tag].addComponent(comp)

    def get_components(self, table):
        ret = []
        for key in table:
            ret.append(self.get_component(key, table[key]))
        return ret

    def get_component(self, key, table):
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
        self.tag.sort()
        for tag in self.tag:
            context = ContextData(tag)
            context.setSource(self.source)
            context.setOutPut(self.outpath)
            self.contexts[tag] = context

class test():
    def pp(self, name):
        self.cc = 6
        exec ('self.{0} = 6'.format( name), globals(), locals())
        print(self.cc)
        print(self.test)

if __name__ == "__main__":
    # test().pp('test')
    PythonParser( Path(utils.get_python_fiel_Path(__file__) + "/../EntitasConfig")).generate()
