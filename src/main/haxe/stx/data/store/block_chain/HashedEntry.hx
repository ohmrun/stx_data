package stx.data.store.block_chain;

@:forward abstract HashedEntry<K>(Couple<Option<Hash>,Entry<K>>){
  public function new(self) this = self;

  public var entry(get,never):Entry<K>;
  private function get_entry():Entry<K>{
    return this.snd();
  }
  public var hash(get,never):Option<Hash>;
  private function get_hash():Option<Hash>{
    return this.fst();
  }

  public function toHashedArrayOfEntry(){
    return HashedArrayOfEntry.make(this.fst(),[this.snd()]);
  }
  public function hashable(){
    return this.map(x -> x.hashable()).tup();
  }
  public function show(){
    var l = this.fst().map(x -> x.truncate(5)).defv("?");
    var r = this.snd().show();
    return '#($l:$r)';
  }
  inline public function toString(){
    return show();
  }
}