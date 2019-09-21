package stx.db.head;

import fig.body.Entity;
import fig.body.ID;

/**
 *  Either a program reference (Bound), or an id that does not yet have a runtime binding.
 */
enum Refers{
    Unbound(id:ID);
    Bound(ent:Entity,on:ID);
}