package stx.data.store.block_chain;

@:forward abstract Entry<K>(Couple<K,Hash>){
  static public function make<K>(k:K,v:Hash):Entry<K>{
    return new Entry(__.couple(k,v));
  }
  public function new(self) this = self;
  public function prj():Couple<K,Hash> return this;

  public var self(get,never):Entry<K>;
  private function get_self():Entry<K> return new Entry(this);

 
  public var key(get,never):K;
  private function get_key():K{
    return this.fst();
  }
  public var points_to(get,never):Hash;
  private function get_points_to():Hash{
    return this.snd();
  }
  public function show(){
    var l = this.fst();
    var r = this.snd().truncate(5);
    return 'Entry($l->$r)';
  }
  public function hashable(){
    return this.tup();
  }
  @:to public function asHashable(){
    return { hashable : hashable };
  }
}