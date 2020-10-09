package stx.data.store;

enum ReadableStoreOp<K,V>{
  RGet(k:K);
  RHas(v:V);
  RItr;
}