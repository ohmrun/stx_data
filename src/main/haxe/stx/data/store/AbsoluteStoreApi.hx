package stx.data.store;

interface AbsoluteStoreApi<K,V> extends SettableStoreApi<K,V>{
  
  public function sif(k:K,iff:V,put:V):Produce<Bool,DbFailure>;
  public function rem(k:K):Execute<DbFailure>;

  public function cls():Execute<DbFailure>;
}