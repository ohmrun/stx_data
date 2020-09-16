package stx.data.store;

interface ReadableStoreApi<K,V>{
  public function get(k:K):Provide<V,DbFailure>;
  public function has(k:K):Proceed<Bool,DbFailure>;

  public function itr():Proceed<Array<K>,DbFailure>;//was in ReferenceStore, but I'm winging it.
}
