from mako.template import Template
import json
import os
import stat
import codecs

entitas_config_dir = os.path.normpath(os.path.split(os.path.realpath(__file__))[0])
def main():
    gen_lua_code()

def open_file(fullname, mode, encoding=None):
    if not os.path.exists(os.path.dirname(fullname)):
        os.makedirs(os.path.dirname(fullname), 0o777, True)

    if os.path.exists(fullname):
        os.chmod(fullname, stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH | stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH)
    return codecs.open(fullname, mode, encoding)

def gen_lua_code():
    
    current_path = os.path.normpath(os.path.split(os.path.realpath(__file__))[0])
    config_path = os.path.join(entitas_config_dir, "entitas.json")

    with open(config_path, 'r') as load_f:
        load_dict = json.load(load_f)

    template = Template(filename=current_path + "/mako/ecs_lua.mako")
    file = open_file(os.path.join(os.path.join(entitas_config_dir, load_dict['output']) ,  "GenerateEcsCore.lua") , 'w')
    content = template.render(config = load_dict)
    content = content.replace('\n','')
    file.write(content)
    file.close()
    print("gencode filish")

if __name__ == "__main__":
    main()