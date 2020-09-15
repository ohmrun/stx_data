package stx.data.store.block_chain;

@:forward abstract ArrayOfHashedEntry<K>(Array<HashedEntry<K>>) from Array<HashedEntry<K>> to Array<HashedEntry<K>>{
  public function toString(){
    return this.map(
      (entry) -> entry.toString()
    );
  }
  public function hashable(){
    return this.map(x -> x.hashable());
  }
  public function show(){
    var a = this.map(x -> x.show()).join(",");
    return '[$a]';
  }
}