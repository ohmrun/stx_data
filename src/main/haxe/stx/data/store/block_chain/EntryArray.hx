package stx.data.store.block_chain;

@:forward abstract EntryArray<K>(Array<Entry<K>>) from Array<Entry<K>> to Array<Entry<K>>{
  public function new(self) this = self;

  public function hashable():Any{
    return this.map( entry -> entry.hashable() );
  }
  public function show(){
    var a = this.map( entry -> entry.show() ).join(",");
    return '[$a]';
  }
  @:noUsing static public function pure<K>(entry:Entry<K>):EntryArray<K>{
    return new EntryArray([entry]);
  }
  public function toString(){
    return show();
  }
  @:to public function asHashable():HasHashable{
    return { hashable : hashable };
  }
  private var self(get,never):EntryArray<K>;
  private function get_self():EntryArray<K> return this;
}