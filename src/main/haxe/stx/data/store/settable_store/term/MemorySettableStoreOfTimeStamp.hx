package stx.data.store.settable_store.term;

import haxe.ds.ObjectMap;

class MemorySettableStoreOfTimeStamp<V> implements stx.data.store.SettableStoreApi<TimeStamp,V>{
  var delegate : ObjectMap<TimeStampDef,V>;

  public function new(){
    this.delegate = new ObjectMap();
  }
  // public function put(v:V):Execute<DataFailure>{
  //   return set((LogicalClock.unit():TimeStampDef),v);
  // }
  public function set(k:TimeStamp,v:V):Execute<DataFailure>{
    this.delegate.set(k,v);
    return Execute.unit();
  }
  public function get(k:TimeStamp):Propose<V,DataFailure>{
    final out = this.delegate.get(k);
    //trace(out);
    var result = __.chunk(out);
    return Propose.fromChunk(result);
  }
  public function has(k:TimeStamp):Produce<Bool,DataFailure>{
    var result = this.delegate.exists(k);
    return Produce.pure(result);
  }

  public function itr():Produce<Cluster<TimeStamp>,DataFailure>{
    var arr = [];
    for(key in this.delegate.keys()){
      arr.push(key);
    }
    return Produce.pure(arr);
  }
  public function del(k:TimeStamp):Execute<DataFailure>{
    this.delegate.remove(k);
    return Execute.unit();
  }
  public function toString(){
    return this.delegate.toString();
  }
}