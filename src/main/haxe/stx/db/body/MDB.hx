package stx.db.body;

import fig.body.query.Path;
import fig.body.ID;
import fig.body.Entity;
import fig.body.Set;

import stx.db.body.Store;
import stx.db.body.Entry;

abstract MDB(Ref<DB>) from Ref<DB>{
    public function new(){
        this = new DB();
    }
    public function create():Entity{
        var next = this.value.create();
        this.value = next.snd();
        return next.fst();
    }
    public function update(entity:Entity,attribute:LPath,value:RNode){
        var next = this.value.update(entity,attribute,value);
        this.value = next;
    }
    public function insert(attribute:LPath,value:RNode):Entity{
        var next = this.value.insert(attribute,value);
        this.value = next.snd();
        return next.fst();
    }
    public function report(entity:Entity,attribute:LPath){
        return this.value.report(entity,attribute);
    }
    public function unbox():DB{
        return this;
    }
}