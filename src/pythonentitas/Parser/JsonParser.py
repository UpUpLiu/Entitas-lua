from src.luaentitas.Parser.BaseParser import BaseParser, ContextData
import json
import os
from mako.template import Template
from pathlib import Path
import src.utils as utils


class JsonParser(BaseParser):
    def load_context_config(self):
        json_files = utils.get_file_list_with_suffix(self.config_path, '.' + self.parser_tag)
        for file_path in json_files:
            if not file_path.endswith('entitas.json'):
                file_name = utils.get_file_name_without_ext(file_path)
                context = ContextData(file_name)
                with open(file_path, 'r') as load_f:
                    text = load_f.read()
                    text = text.replace(' ', '')
                    context.setOutPut(self.outpath)
                    context.setSource(self.source)
                    context.setComponents( json.loads(text))
                self.contexts.append(context)

    def load_base_config(self):
        with open(self.base_config_file , 'r') as load_f:
            text = load_f.read()
            text = text.replace(' ', '')
            load_dict = json.loads(text)
        self.source = load_dict['source']
        self.outpath =  self.config_path / load_dict['output']
        self.namespace = load_dict['namespace']
        self.parser_tag = load_dict['parse']

if __name__ == "__main__":
    JsonParser().generate()
