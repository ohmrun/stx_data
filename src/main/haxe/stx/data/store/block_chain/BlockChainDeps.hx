package stx.data.store.block_chain;


typedef BlockChainDepsDef<K,V> = {
  K : { 
    hash        : K -> Hash,
    eq          : K -> K -> Bool,
    serialize   : K -> String,
    unserialize : String -> K
  },
  V : { 
    hash        : V -> Hash,
    serialize   : V -> String,
    unserialize : String -> V
  }
};
@:forward abstract BlockChainDeps<K,V>(BlockChainDepsDef<K,V>) from BlockChainDepsDef<K,V>{
  public function new(self) this = self;
  static public function form<K,V>():BlockChainDepsDef<K,V>{
    return {
      K : {
        hash : (k:K) -> {
          return new Hash(Sha1.encode(Serialize.encode(k)));
        },
        eq : (l,r)                    -> l == r,
        serialize : (k:K)             -> Serialize.encode(k),
        unserialize : (string:String) -> Serialize.decode(string)
      }, 
      V : {
        hash : (v:V) -> {
          return new Hash(Sha1.encode(Serialize.encode(v)));
        },
        serialize : (v:V)             -> Serialize.encode(v),
        unserialize : (string:String) -> Serialize.decode(string)
      }
    };
  }
  static public function unit<K,V>():BlockChainDeps<K,V>{
    return form();
  } 
}