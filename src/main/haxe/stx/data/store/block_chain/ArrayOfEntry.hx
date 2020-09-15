package stx.data.store.block_chain;

@:forward abstract ArrayOfEntry<K>(EntryArray<K>) from EntryArray<K> to EntryArray<K>{
  public function toString(){
    return this.map(
      (entry) -> entry.toString()
    );
  }
}