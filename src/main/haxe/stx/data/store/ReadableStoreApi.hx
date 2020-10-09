package stx.data.store;

interface ReadableStoreApi<K,V>{
  public function get(k:K):Propose<V,DbFailure>;
  public function has(k:K):Produce<Bool,DbFailure>;

  public function itr():Produce<Array<K>,DbFailure>;//was in ReferenceStore, but I'm winging it.
}
