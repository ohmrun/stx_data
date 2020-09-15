package stx.data.store.block_chain;

@:forward abstract HashedArrayOfEntry<K>(Couple<Option<Hash>,ArrayOfEntry<K>>) from Couple<Option<Hash>,ArrayOfEntry<K>>{
  public function new(self) this = self;
  @:noUsing static public function unit<K>():HashedArrayOfEntry<K>{
    return make(None,[]);
  }
  @:noUsing static public function make<K>(hash:Option<Hash>,array:ArrayOfEntry<K>){
    return new HashedArrayOfEntry(__.couple(hash,array));
  }
  @:noUsing static public function pure<K>(entry:Entry<K>){
    var arr   = ArrayOfEntry.pure(entry);
    var hash  = Helper.hash(arr);
    return make(Some(hash),arr);
  }
  public function mod(fn:ArrayOfEntry<K>->ArrayOfEntry<K>):HashedArrayOfEntry<K>{
    return make(this.fst(),fn(this.snd()));
  }
  public function rehash(){
    return make(Helper.hash(this.snd()),this.snd());
  }
  public var hash(get,never):Option<Hash>;
  private function get_hash():Option<Hash>{
    return this.fst();
  }
  public var data(get,never):ArrayOfEntry<K>;
  private function get_data():ArrayOfEntry<K>{
    return this.snd();
  }
  public function hashable():Any{
    return this.map(
      arr -> arr.hashable()
    ).tup();
  }
  public function show(){
    var l = this.fst().map(x -> x.truncate(5));
    var r = this.snd().show();
    return '($l::$r)';
  }
  public function toString(){
    return show();
  }
  public function snoc(item:Entry<K>){
    return make(this.fst(),this.snd().snoc(item));
  }
  public function any(fn:Entry<K>->Bool){
    return this.snd().any(fn);
  }
  @:to public function asHashable():HasHashable{
    return {
      hashable : hashable
    }
  }
}