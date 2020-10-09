package stx.data.store.block_chain.term;

import stx.data.store.settable_store.MemorySettableStoreOfString;

class MemoryBlockChain<K,V> extends BlockChain<K,V>{
  public function new(deps){
    super(
      deps,
      new MemorySettableStoreOfString(),
      new MemorySettableStoreOfString(),
      new MemorySettableStoreOfString()
    );
  }
}