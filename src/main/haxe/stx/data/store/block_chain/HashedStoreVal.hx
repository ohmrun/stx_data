package stx.data.store.block_chain;

@:forward abstract HashedStoreVal<K,V>(Couple<Hash,StoreVal<K,V>>){
  @:noUsing static public function make(hash,node){
    return new HashedStoreVal(__.couple(hash,node));
  }
  public function new(self) this = self;
  public var hash(get,never):Hash;
  private function get_hash():Hash{
    return this.fst();
  }
}