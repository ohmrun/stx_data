package stx.data.store.block_chain;

@:forward abstract ArrayOfEntry<K>(Array<Entry<K>>) from Array<Entry<K>> to Array<Entry<K>>{

  static public function unit<K>():ArrayOfEntry<K>{return new ArrayOfEntry([]);}
  public function new(self) this = self;

  public function hashable():Any{
    return this.map( entry -> entry.hashable() );
  }
  public function serializable():Array<Tup2<K,Hash>>{
    return this.map(entry -> entry.tup());
  }
  public function show(){
    var a = this.map( entry -> entry.show() ).join(",");
    return '[$a]';
  }
  @:noUsing static public function pure<K>(entry:Entry<K>):ArrayOfEntry<K>{
    return new ArrayOfEntry([entry]);
  }
  public function toString(){
    return show();
  }
  @:to public function asHashable():HasHashable{
    return { hashable : hashable };
  }
  private var self(get,never):ArrayOfEntry<K>;
  private function get_self():ArrayOfEntry<K> return this;
}