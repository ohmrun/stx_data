package stx.data.store;

enum AbsoluteStoreOp<K,V>{
  AGet(k:K);
  AHas(v:V);
  ASet(k:K,v:V)
  AItr;
  ASif(k:K,iff:V,put:V);
  ARem(k:K);
}