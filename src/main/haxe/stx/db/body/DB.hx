package stx.db.body;

import stx.db.head.DB in DBT;

abstract DB(DBT) from DBT{
    public function new(){
        this = tuple2(new Embed(),new Store());
    }
    public function lookup(entity:Entity):Option<ID>{
        return this.fst().unpack(entity.unbox());
    }
    public function create():Tuple2<Entity,DB>{
        var id                  = thx.Uuid.create();
        var entity : Entity     = this.fst().pack(id);

        return tuple2(entity,map(
            function(store){
                return store.introduce(entity);
            }
        ));
    }
    public function update(entity:Entity,attribute:LPath,value:RNode):DB{
        return this.map(
            function(store){
                return store.append(Arc.create(entity,Register.create(attribute,value)));
            }
        );
    }
    public function insert(attribute:LPath,value:RNode):Tuple2<Entity,DB>{
        var val = create();
        return tuple2(val.fst(),val.snd().update(val.fst(),attribute,value));
    }
    public function report(entity:Entity,attribute:LPath){
        return Future.sync(this.snd().report(entity,attribute));
    }
    function map(fn:Store->Store):DB{
        return this.map(fn);
    }
    /*
    public function toString():String{
        trace("called");
        var snd = this.snd().toString();
        return '$snd';
    }*/
}