from pathlib import Path
from Parser import PythonParser
import utils
# from src.luaentitas.Parser.LuaParser import LuaParser
if __name__ == '__main__':
    PythonParser( Path(utils.get_python_fiel_Path(__file__) + "/pythonentitas/EntitasConfig/entitas.lua")).generate()
    # LuaParser().generate()