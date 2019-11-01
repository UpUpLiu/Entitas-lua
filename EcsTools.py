from mako.template import Template
import json
import os
import codecs
import stat
def main():
    test()


def open_file(fullname, mode, encoding=None):
    if not os.path.exists(os.path.dirname(fullname)):
        os.makedirs(os.path.dirname(fullname), 0o777, True)

    if os.path.exists(fullname):
        os.chmod(fullname, stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH | stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH)
    return codecs.open(fullname, mode, encoding)

def test():
    current_path = os.path.normpath(os.path.split(os.path.realpath(__file__))[0])
    entitas_config_dir = current_path
    config_path = os.path.join(entitas_config_dir, "entitas.json")

    with open(config_path, 'r') as load_f:
        text = load_f.read()
        text = text.replace(' ','')
        load_dict = json.loads(text)


    template = Template(filename=current_path + "/mako/ecs_lua_context.mako",
                        module_directory= os.path.join(current_path ,'makoCache'))
    file_name = os.path.join(os.path.join(entitas_config_dir, load_dict['output']), "GenerateEcsCore.lua") 
    file = open_file(file_name , 'w')
    for key in load_dict['contexts']:
        print(key)
        content = template.render(
            context_name=key,
            contexts=load_dict['contexts'][key]
        )
        content = content.replace('\n','')
        file.write(content)

    file.close()
    print("gen entitas code success")


if __name__ == "__main__":
    main()