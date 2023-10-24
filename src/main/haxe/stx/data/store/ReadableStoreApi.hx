package stx.data.store;

interface ReadableStoreApi<K,V>{
  public function get(k:K):Propose<V,DataFailure>;
  public function has(k:K):Produce<Bool,DataFailure>;

  public function itr():Produce<Cluster<K>,DataFailure>;//was in ReferenceStore, but I'm winging it.
}
