package stx.db.body;

import fig.head.data.Primitive;
import stx.db.head.RNode in RNodeT;

abstract RNode(RNodeT) from RNodeT to RNodeT{
    @:op(A==B)
    public function equals(that:RNodeT){
        function handler(l:RNodeT,r:RNodeT){
            return switch([l,r]){
                case [Local(l),Local(r)]                :  l == r;
                case [Remote(e0,p0),Remote(e1,p1)]      : e0 == e1 && p0 == p1;
                default : false;
            }
        };
        return handler(this,that);
    }
    @:from static public function fromPrimitive(i:Primitive):RNode{
        return Local(i);
    }
    @:from static public function fromInt(i:Int):RNode{
        return Local(Integer(i));
    }
    @:from static public function fromString(s:String):RNode{
        return Local(Characters(s));
    }
    public function toString(){
        return switch(this){
            case Local(v)       : '${v.toString()}';
            case Remote(e,p)    : '${e.toString()}/$p';
        }
    }
}