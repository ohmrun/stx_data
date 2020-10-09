package stx.data.store.settable_store;

class MemorySettableStoreOfString<V> implements stx.data.store.SettableStoreApi<String,V>{
  var delegate : StringMap<V>;

  public function new(){
    this.delegate = new StringMap();
  }
  public function set(k:String,v:V):Execute<DbFailure>{
    this.delegate.set(k,v);
    return Execute.unit();
  }
  public function get(k:String):Propose<V,DbFailure>{
    var result = __.chunk(this.delegate.get(k));
    return Propose.fromChunk(result);
  }
  public function has(k:String):Produce<Bool,DbFailure>{
    var result = this.delegate.exists(k);
    return Produce.pure(result);
  }

  public function itr():Produce<Array<String>,DbFailure>{
    var arr = [];
    for(key in this.delegate.keys()){
      arr.push(key);
    }
    return Produce.pure(arr);
  }

}