package stx.db.head;

import stx.db.body.RNode;
import stx.db.body.Set;
import stx.db.head.Entry;

typedef Store  = {
    var entities : ReadonlyArray<Entity>;
    var values   : Set;
}