package stx.data;


typedef Serialize                               = stx.data.store.Serialize;
typedef ReadableStoreApi<K,V>                   = stx.data.store.ReadableStoreApi<K,V>;
typedef SettableStoreApi<K,V>                   = stx.data.store.SettableStoreApi<K,V>;
typedef MemorySettableStoreOfString<V>          = stx.data.store.settable_store.MemorySettableStoreOfString<V>;
typedef MemorySettableStoreOfTimeStamp<V>       = stx.data.store.settable_store.term.MemorySettableStoreOfTimeStamp<V>;

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
class SettableStoreLift{
  static public function del_all<K,V>(self:SettableStoreApi<K,V>,keys:Cluster<K>):Execute<DataFailure>{
    return Execute.sequence(
      function (k:K):Execute<DataFailure>{
        return self.del(k);
      },
      keys
    );
  }
  /**
   * Returns values and deletes keys
   * @param opt 
   * @return .fold(
          ok -> __.accept(ok),
          e  -> __.reject(e),
          () -> __.accept([])
        )
   */
  static public function rem_all<K,V>(self:SettableStoreApi<K,V>,keys:Cluster<K>):Produce<Cluster<V>,DataFailure>{
    return self.get_all(keys)
      .command(
        __.command(
          vals -> self.del_all(keys)
        )
    );
  }
  static public function get_all<K,V>(self:SettableStoreApi<K,V>,keys:Cluster<K>):Produce<Cluster<V>,DataFailure>{
    return Produce.lift(
      Propose.lift(
        Propose.bind_fold(
          function (k:K,cl:Cluster<V>){
            __.log().trace('$k');
            __.log().trace('$self');
            return self.get(k).produce().propose(
              (chk) -> (chk).fold(
                opt -> opt.fold(
                  ok -> Propose.pure(cl.snoc(ok)),
                  () -> Propose.fromRefuse(__.fault().of(E_Data_KeyNotFound(k)))
                ),
                no -> Propose.fromRefuse(no)
              )
            );
          },
          keys,
          [].imm()
        ).toFletcher()
      ).toFletcher().map(
        (opt:Chunk<Cluster<V>,DataFailure>) -> (opt).fold(
          ok -> __.accept(ok),
          e  -> __.reject(e),
          () -> __.accept([])
        )
      )
    );
  }
}