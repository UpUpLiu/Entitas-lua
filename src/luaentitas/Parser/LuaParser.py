# -*- coding: utf-8 -*-
from pathlib import Path

from src.luaentitas.Parser.BaseParser import BaseParser, ContextData, Component, MuIndex
import json
import src.utils as utils
from lupa import *

lua = LuaRuntime()

class LuaParser(BaseParser):
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
                    for comp in components:
                        for tag in comp.tag:
                            self.contexts[tag].addComponent(comp)

    def load_context_index(self):
        with open(self.context_index_path , 'r') as load_f:
            text = load_f.read()
            config = lua.compile(text)()
        for tag in config :
            context_index = config[tag].index
            context = self.contexts[tag]
            if context_index:
                context_index_data = context_index.data
                mu_index = MuIndex()
                mu_index.setFuncName(context_index.funcName)
                for comp_name in context_index_data:
                    mu_index.addData(comp_name,  context_index_data[comp_name])

                context.addContextMuIndex(mu_index)

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
        self.load_context_index()


if __name__ == "__main__":
    LuaParser().generate()
