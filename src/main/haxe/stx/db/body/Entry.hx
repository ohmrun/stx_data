package stx.db.body;

import fig.head.data.Entry;
import fig.head.data.Primitive;
import stx.db.head.Entry in EntryT;

abstract Entry(EntryT) from EntryT to EntryT{
    public function new(self){
        this = self;
    }
    @:from static public function fromEntity<T>(e:Entity):Entry{
        return Vertex(e);
    }
    @:from static public function fromBool(b:Bool):Entry{
        return Symbol(Boolean(b));
    }
    @:from static public function fromInt(i:Int):Entry{
        return Symbol(Integer(i));
    }
    @:from static public function fromFloat(f:Float):Entry{
        return Symbol(FloatingPoint(f));
    }
    @:from static public function fromString(i:String):Entry{
        return Symbol(Characters(i));
    }

}