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
  public function get(k:String):Provide<V,DbFailure>{
    var result = __.chunk(this.delegate.get(k));
    return Provide.fromChunk(result);
  }
  public function has(k:String):Proceed<Bool,DbFailure>{
    var result = this.delegate.exists(k);
    return Proceed.pure(result);
  }

  public function itr():Proceed<Array<String>,DbFailure>{
    var arr = [];
    for(key in this.delegate.keys()){
      arr.push(key);
    }
    return Proceed.pure(arr);
  }

}