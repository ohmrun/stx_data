package stx.data.store.block_chain;

class Global{
  static public function hash<T>(v:T):Hash{
    return Hash.pure(
      { 
        hashable : () -> (v:Any)
      }
    );
  }
}