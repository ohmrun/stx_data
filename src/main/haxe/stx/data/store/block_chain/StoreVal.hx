package stx.data.store.block_chain;

enum StoreValSum<K,V>{
  NData(v:V);
  NEdge(k:K);
}
@:using(stx.data.store.block_chain.StoreVal.StoreValLift)
abstract StoreVal<K,V>(StoreValSum<K,V>) from StoreValSum<K,V> to StoreValSum<K,V>{
  static public var _(default,never) = StoreValLift;
  public function new(self) this = self;
  static public function lift<K,V>(self:StoreValSum<K,V>):StoreVal<K,V> return new StoreVal(self);
  
  

  public function prj():StoreValSum<K,V> return this;
  private var self(get,never):StoreVal<K,V>;
  private function get_self():StoreVal<K,V> return lift(this);

  public function hashable():Any{
    return this;
  }
  @:to public function asHashable():HasHashable{
    return { hashable : hashable };
  }
}
class StoreValLift{
  static public function identify<K,V>(self:StoreValSum<K,V>){
    return HashedStoreVal.make(Helper.hash(StoreVal.lift(self)),self);
  }
  static public function fold<K,V,Z>(self:StoreVal<K,V>,ndata:V->Z,nedge:K->Z):Z{
    return switch(self){
      case NData(t) : ndata(t);
      case NEdge(s) : nedge(s);
    }
  }
  static public function get_data<K,V>(self:StoreVal<K,V>):Option<V>{
    return fold(
      self,
      Option.pure,
      (_) -> Option.unit()
    );
  }
}