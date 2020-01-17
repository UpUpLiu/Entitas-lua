
from ...Entitas.ComponentContext import ComponentContext as Context
class ComponentContext(Context):
    def __init__(self):
        super().__init__()


    def create_component(self, name):
        e = self.create_entity()
        e.replaceName( name[0].lower() + name[1:], name[0].upper() + name[1:])

        return e