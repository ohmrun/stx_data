package stx.data.store.block_chain;


interface Notifier<K,V>{
  public function notify(key:K,val:Option<V>):Void;
}