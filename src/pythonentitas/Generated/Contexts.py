from .. import AttrContext
from .. import AttrEntity
from .. import ComponentContext
from .. import ComponentEntity
from .. import ContextContext
from .. import ContextEntity


class Contexts:

    attr = AttrContext()
    attr.set_entity_class(AttrEntity)

    component = ComponentContext()
    component.set_entity_class(ComponentEntity)

    context = ContextContext()
    context.set_entity_class(ContextEntity)
