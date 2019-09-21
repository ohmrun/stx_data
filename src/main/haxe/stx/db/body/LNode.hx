package stx.db.body;

import stx.db.head.LNode in LNodeT;

abstract LNode(LNodeT) from LNodeT to LNodeT{
    static public function int(i){
        return fromInt(i);
    }
    static public function string(s){
        return fromString(s);
    }  
    @:from static public function fromInt(int:Int):LNode{
        return Offset(int);
    }
    @:from static public function fromString(str:String):LNode{
        return Choice(str);
    }
    @:from static public function fromIndex(v:fig.body.Index):LNode{
        return switch(v){
            case fig.head.data.Index.Choice(s) : Choice(s);
            case fig.head.data.Index.Offset(i) : Offset(i);
        }
    }
}