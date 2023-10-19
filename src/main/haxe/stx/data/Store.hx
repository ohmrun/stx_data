package stx.data;


typedef Serialize                               = stx.data.store.Serialize;
typedef ReadableStoreApi<K,V>                   = stx.data.store.ReadableStoreApi<K,V>;
typedef SettableStoreApi<K,V>                   = stx.data.store.SettableStoreApi<K,V>;
typedef MemorySettableStoreOfString<V>          = stx.data.store.settable_store.MemorySettableStoreOfString<V>;


typedef AbsoluteStoreApi<K,V>                   = stx.data.store.AbsoluteStoreApi<K,V>;


enum Step{
  Ind(index:Blob);
  Acc(value:String);
}
typedef CursorDef                               = Array<Step>;
abstract Cursor(CursorDef) from CursorDef{
  @:arrayAccess public function acc(b:Blob):Cursor  return this.snoc(Ind(b));
  @:op(A.B) public function get(s:String):Cursor    return this.snoc(Acc(s));
}
typedef FigureDef                               = SpineSum<Cursor>;
abstract Figure(FigureDef) from FigureDef{

}
