
from pythonentitas.Generated.Entitas.ContextEntity import ContextEntity as Entity
class ContextEntity(Entity):
    def __init__(self):
        super().__init__()

    def addComponent(self, comp):
        if not self.hasComponents():
            comps = []
        else:
            comps = self.components.value
        comps.append(comp)
        self.replaceComponents(comps)
        return