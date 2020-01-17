from ...Entitas.ComponentEntity import ComponentEntity as Entity
from ...Entitas.AttrEntity import AttrEntity as AttrEntity


def call_class_func(object, func_name, *arg):
    assert isinstance(func_name, str), 'func_name must be a string'
    if func_name not in object.__dict__:
        func = getattr(object, func_name, None)
        if func is not None:
            func(*arg)
            return True
    # print('object dont have function ' + func_name)

class ComponentEntity(Entity):
    def __init__(self):
        super().__init__()

    def addAttr(self, key, data):
        key = key.replace(' ', '')
        if self.hasAttrs():
            atts = self.attrs.value
        else:
            atts = []
        from pythonentitas.Generated.Entitas.Contexts import Contexts
        attr = Contexts.attr.create_entity()
        attr.replaceName(key)
        if data is not None:
            attr.set_attr_data(data)
        attr.replaceComponent(self)
        atts.append(attr)
        self.replaceAttrs(atts)
        return attr

    def get_params_str(self, sep=', ', b=[]):
        properties = self.get_properties()
        b = []
        for item in properties:
            sp_ret = item.replace(' ', '').split(':')
            b.append('"' + sp_ret[0] + '"')
        return sep.join(b)

    def get_params(self, sep=', ', b=[]):
        properties = self.get_properties()
        b = []
        for item in properties:
            sp_ret = item.replace(' ', '').split(':')
            b.append(sp_ret[0])
        return sep.join(b)

    def get_properties_define(self):
        properties = self.get_properties()
        ret = ''
        for i in range(len(properties)):
            properties[i] = properties[i].replace(' ', '')
            sp_ret = properties[i].split(':')
            ret += '---@param {0} {1}\n'.format(sp_ret[0], sp_ret[1])
        return ret

    def set_component_data(self, dates):
        for index in range(len(dates)):
            data : str = dates[index]
            if data.find('@') != -1: # 有index
                spret = data.split('@')
                spret[0] = spret[0].replace(' ', '')
                dates[index] = spret[0]
                attr = self.addAttr(spret[1], None)
                attr.replaceParseAttr(spret[0])
        self.replaceDates(dates)

    def get_properties(self):
        if self.hasDates():
            return self.dates.value
        else:
            return []

