
from ... import ContextGenerateEntity as Entity
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

    def add_custom_inc(self, path):
        if not self.hasCustomInc():
            incs = []
        else:
            incs = self.customInc.value
        incs.append(path)
        self.replaceCustomInc(incs)
        return