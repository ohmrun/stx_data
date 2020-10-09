package stx.data.store;

enum SettableStoreOp<K,V>{
  SGet(k:K);
  SHas(v:V);
  SSet(k:K,v:V)
  SItr;
}
