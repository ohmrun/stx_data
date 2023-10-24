package stx.data.store.settable_store;

class MemorySettableStoreOfString<V> implements stx.data.store.SettableStoreApi<String,V>{
  var delegate : StringMap<V>;

  public function new(){
    this.delegate = new StringMap();
  }
  public function set(k:String,v:V):Execute<DataFailure>{
    this.delegate.set(k,v);
    return Execute.unit();
  }
  public function get(k:String):Propose<V,DataFailure>{
    var result = __.chunk(this.delegate.get(k));
    return Propose.fromChunk(result);
  }
  public function has(k:String):Produce<Bool,DataFailure>{
    var result = this.delegate.exists(k);
    return Produce.pure(result);
  }

  public function itr():Produce<Cluster<String>,DataFailure>{
    var arr = [];
    for(key in this.delegate.keys()){
      arr.push(key);
    }
    return Produce.pure(arr);
  }
  public function del(k:String):Execute<DataFailure>{
    this.delegate.remove(k);
    return Execute.unit();
  }
}