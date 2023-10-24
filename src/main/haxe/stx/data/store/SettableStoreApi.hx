package stx.data.store;

interface SettableStoreApi<K,V> extends ReadableStoreApi<K,V>{
  public function set(k:K,v:V):Execute<DataFailure>;
  public function del(k:K):Execute<DataFailure>;
}