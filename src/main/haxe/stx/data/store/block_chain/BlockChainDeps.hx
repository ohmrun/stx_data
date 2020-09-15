package stx.data.store.block_chain;

typedef BlockChainDepsDef<K,V> = {
  K : { 
    hash : K -> String,
    eq   : K -> K -> Bool
  },
  V : { 
    hash : V -> String
  }
};
@:forward abstract BlockChainDeps<K,V>(BlockChainDepsDef<K,V>) from BlockChainDepsDef<K,V>{
  public function new(self) this = self;
  static public function form<K,V>():BlockChainDepsDef<K,V>{
    var serializer = new Serializer();
        serializer.useCache = true;
    return {
      K : {
        hash : (k:K) -> {
          serializer.serialize(k);
          return Sha1.encode(serializer.toString());
        },
        eq : (l,r) -> l == r
      },
      V : {
        hash : (v:V) -> {
          serializer.serialize(v);
          return Sha1.encode(serializer.toString());
        }
      }
    };
  }
  static public function unit<K,V>():BlockChainDeps<K,V>{
    return form();
  } 
}