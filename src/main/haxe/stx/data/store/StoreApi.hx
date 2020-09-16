package stx.data.store;

interface StoreApi<K,V> extends SettableStoreApi<K,V>{
  
  public function sif(k:K,iff:V,put:V):Proceed<Bool,DbFailure>;
  public function rem(k:K):Execute<DbFailure>;

  public function close():Execute<DbFailure>;
}