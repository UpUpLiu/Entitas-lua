import os
from pathlib import Path

from mako.template import Template

import utils
from pythonentitas.Generated.Entitas.ContextEntity import ContextEntity


class BaseAttrHandler:
    context: ContextEntity

    def __init__(self, attr_define):
        self.attr_define = attr_define
        self.className = self.__class__.__name__
        self.script_path = self.get_script_path()
        self.mako_path = self.script_path / 'mako' / (self.className + ".mako")
        self.context = None
        return

    def get_script_path(self):
        return  Path(utils.get_python_fiel_Path(__file__) )

    def set_contexts(self, context):
        self.context = context

    def set_attrs(self, attrs):
        self.attrs = attrs

    def get_out_file_name(self):
        return self.attr_define.Key

    def start_handle(self):
        return
