package stx.db.body;

import fig.head.data.Set in SetT;

@:forward(filter) abstract Set(SetT<RNode>){
    public function new(?self:ReadonlyArray<Arc<RNode>>){
        if(self == null){
            self = ([]:ReadonlyArray<Arc<RNode>>);
        }
        this = self;
    }
    public function append(arc:Arc<RNode>):Set{
        var next = this.concat([arc]);
        return new Set(next);
    }
    public function iterator():Iterator<Arc<RNode>>{
        return this.iterator();
    }
    @:to public function toIterable():Iterable<Arc<RNode>>{
        return this.toArray();
    }
    /*
    public function toString(){
        return toStringWith(
            function(rn){
                return rn.toString();
            }
        );
    }
    public function toStringWith(fn:RNode->String){
        return this.map(
            function(a:Arc<RNode>){
                return a.toStringWith(fn);
            }
        ).join("??");
    }*/

}