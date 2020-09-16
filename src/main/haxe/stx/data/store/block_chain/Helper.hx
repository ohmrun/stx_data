package stx.data.store.block_chain;

class Helper{
  @:noUsing static public function hash<T:HasHashable>(v:T):Hash{
    return new Hash(Sha1.encode(Serialize.encode(v.hashable())));
  }
}