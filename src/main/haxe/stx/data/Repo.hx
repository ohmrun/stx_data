package stx.data;

@:publicFields typedef RepoLookupDef<T,I> = {
  final lookup : (t:T) -> I;
}
interface RepoLookupApi<T,I>{
  public final lookup : (t:T) -> I;
}
@:structInit class RepoLookup<T,I> implements RepoLookupApi<T,I> {
  public function new(lookup){
    this.lookup = lookup;
  } 
  public final lookup : (t:T) -> I;
}
typedef RepoInsertDef<Insert_T> = {
  public final secure : (dyn:Dyn ) -> Insert_T;
}
interface RepoInsertApi<Insert_T>{
  public final secure : (dyn:Dyn ) -> Insert_T;
}
@:structInit class RepoInsertCls<Insert_T>{
  public function new(secure){
    this.secure = secure;
  }
  public final secure : (dyn:Dyn ) -> Insert_T;
}
@:forward abstract RepoInsert<Insert_T>(RepoInsertCls<Insert_T>) from RepoInsertCls<Insert_T> to RepoInsertCls<Insert_T>{
  @:from static public function fromFn<Insert_T>(fn:Dyn->Insert_T):RepoInsert<Insert_T>{
    return new RepoInsertCls(fn);
  }
}
typedef RepoUpdateDef<Insert_T,Update_T,Index_T> = RepoLookupDef<Update_T,Index_T> & {
  public final harden : ( issued:Update_T ) -> Insert_T;
}
interface RepoUpdateApi<Insert_T,Update_T,Index_T> extends RepoLookupApi<Update_T,Index_T>{
  public final harden : ( issued:Update_T ) -> Insert_T;
}
@:structInit class RepoUpdateCls<Insert_T,Update_T,Index_T> implements RepoUpdateApi<Insert_T,Update_T,Index_T> extends RepoLookup<Update_T,Index_T>{
  public function new(lookup,harden){
    super(lookup);
    this.harden = harden;
  }
  public final harden : ( issued:Update_T ) -> Insert_T;
}
@:forward abstract RepoUpdate<Insert_T,Update_T,Index_T>(RepoUpdateCls<Insert_T,Update_T,Index_T>) from RepoUpdateCls<Insert_T,Update_T,Index_T> to RepoUpdateCls<Insert_T,Update_T,Index_T>{
  @:from static public function fromTup2<Insert_T,Update_T,Index_T>(self:Tup2<Update_T->Index_T,Update_T->Insert_T>):RepoUpdate<Insert_T,Update_T,Index_T>{
    return switch(self) {
      case tuple2(l,r)  : new RepoUpdateCls(l,r);
    }
  }
}



typedef RepoIssuedPrimaryDef<IssuedPrimary_T,Index_T> = RepoLookupDef<IssuedPrimary_T,Index_T> & {
  public final secure : (dyn:Dyn) -> IssuedPrimary_T;
}
interface RepoIssuedPrimaryApi<IssuedPrimary_T,Index_T> extends RepoLookupApi<IssuedPrimary_T,Index_T>{
  public final secure : (dyn:Dyn) -> IssuedPrimary_T;
}
@:structInit class RepoIssuedPrimaryCls<IssuedPrimary_T,Index_T> implements RepoIssuedPrimaryApi<IssuedPrimary_T,Index_T> extends RepoLookup<IssuedPrimary_T,Index_T>{
  public function new(lookup,secure){
    super(lookup);
    this.secure = secure;
  }
  public final secure : (dyn:Dyn) -> IssuedPrimary_T;
} 
@:forward abstract RepoIssuedPrimary<IssuedPrimary_T,Index_T>(RepoIssuedPrimaryCls<IssuedPrimary_T,Index_T>) from RepoIssuedPrimaryCls<IssuedPrimary_T,Index_T> to RepoIssuedPrimaryCls<IssuedPrimary_T,Index_T>{
  @:from static public function fromTup2<IssuedPrimary_T,Index_T>(self:Tup2<IssuedPrimary_T->Index_T,Dyn->IssuedPrimary_T>):RepoIssuedPrimary<IssuedPrimary_T,Index_T>{
    return switch(self) {
      case tuple2(l,r)  : new RepoIssuedPrimaryCls(l,r);
    }
  }
}