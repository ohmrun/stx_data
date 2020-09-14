package stx.data;

import stx.data.Test;
import stx.data.TestBonce;

typedef BlockStoreOneDepsDef<K,V> = {
  K : { 
    hash : K -> String,
    eq   : K -> K -> Bool
  },
  V : { 
    hash : V -> String
  }
};
@:forward abstract BlockStoreOneDeps<K,V>(BlockStoreOneDepsDef<K,V>) from BlockStoreOneDepsDef<K,V>{
  public function new(self) this = self;
  static public function form<K,V>():BlockStoreOneDepsDef<K,V>{
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
  static public function unit<K,V>():BlockStoreOneDeps<K,V>{
    return form();
  } 
}