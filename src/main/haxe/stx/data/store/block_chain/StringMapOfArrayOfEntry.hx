package stx.data.store.block_chain;

@:forward abstract StringMapOfArrayOfEntry<K>(StringMap<ArrayOfEntry<K>>){
  public function new() this = new StringMap();
  public function get(hash:Hash):ArrayOfEntry<K>{
    return this.get(hash.prj());
  }
  public function set(hash:Hash,data:ArrayOfEntry<K>){
    this.set(hash.prj(),data);
  }
}