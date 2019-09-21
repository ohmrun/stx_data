package stx.db.body;

import stx.db.body.Set;

using thx.Iterables;
import stx.db.head.Store in StoreT;
//import fig.head.data.Store in StoreT;


abstract Store(StoreT) from StoreT{
    public function new(){
        var Set : Set                            = new Set();
        var set : ReadonlyArray<fig.body.Entity>        = [];
        var self : StoreT = { entities : set, values : Set };
        this = self;
    }
    public var entities(get,never) : ReadonlyArray<Entity>;
    private function get_entities(){
        return this.entities;
    }
    public var values(get,never) : Set;
    private function get_values(){
        return this.values;
    }
    public function introduce(e:Entity):Store{
        var next_entities = this.entities.append(e);
        return {
            entities : next_entities,
            values  : this.values
        };
    }
    public function append(entry:Arc<RNode>):Store{
        return {
            entities : entities,
            values  : values.append(entry)
        };
    }
    /*
    public function report(entity:Entity,path:LPath):Set{
        return new Set(this.values.filter(
            function handler(v){
                return switch(v){
                    case { register : tuple2(path0,_) }       : 
                        var p  = path0.unbox();
                        path.equals(p);
                    default                              : false;
                }
            }
        ));
    }*/
    /*public function toString():String{
        return 'store/${values.toStringWith(
            function(b:RNode){
                return b.toString();
            }
        )}';
    }*/
}