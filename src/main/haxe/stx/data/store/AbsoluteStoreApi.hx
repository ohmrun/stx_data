package stx.data.store;

interface AbsoluteStoreApi<K,V> extends SettableStoreApi<K,V>{
  
  public function sif(k:K,iff:V,put:V):Produce<Bool,DataFailure>;
  public function rem(k:K):Execute<DataFailure>;

  public function cls():Execute<DataFailure>;
}