package stx.db.head;

import fig.body.ID;
import stx.db.body.LPath;

enum RNode{
    Local(v:Primitive);
    Remote(entity:ID,?path:LPath);
}