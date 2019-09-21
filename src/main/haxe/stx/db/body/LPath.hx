package stx.db.body;

import stx.db.head.LNode in LNodeT;
import fig.body.Address;
import fig.head.Data.Parameter;
import fig.head.Data.Path in LPathT;
import fig.body.query.Path in RegPathT;

import fig.body.Path in LPathA;

abstract LPath(LPathA<LNode>) from LPathA<LNode>{

    @:from static public function fromAddress(arr:Address):LPath{
        return new LPath(
            fig.body.Path.fromArray(
                arr.unbox().map(
                    function(x){
                        return LNode.fromIndex(x);
                    }
                )
            )
        );
    }
    @:arrayAccess
    public function stringAccess(str:String):LPath{
        return Down(Some(LNodeT.Choice(str)),this.unbox());
    }
    @:arrayAccess
    public function intAccess(int:Int):LPath{
        return Down(Some(Offset(int)),this.unbox());
    }
    @:from static public function fromRegistryPath(r:RegPathT):LPath{
        return new LPath(
            r.unbox().map(LNode.fromIndex)
        );
    }
    /*
    @:to public function toRegistryPath():RegPathT{
        return this.map(
            function(o){
                return switch
            }
        )
    }*/
    @:from static public function fromLPathT(p:LPathT<LNode>){
        return new LPath(p);
    }
    static public function unit():LPath{
        return LPathA.unit();
    }
    public function new(self){
        this = self;
    }
    public function unbox():LPathT<LNode>{
        return this.unbox();
    }
    public function append(v:LNode):LPath{
        return this.append(v);
    } 
    @:arrayAccess public function getString(str:String):LPath{
        return append(LNode.string(str));
    }
    @:arrayAccess public function getInt(int:Int):LPath{
        return append(LNode.int(int));
    }
    public function parent():LPath{
        return this.parent();
    }
    public function equals(that:LPathT<LNode>){
        return this.equalsWith(that,
            function(l,r){
                return l == r;
            }
        );
    }
}