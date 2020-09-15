package stx.data.store;

import stx.data.store.block_chain.*;

class BlockChain<K,V>{
  private var serializer : Serializer;

  public var deps(default,null):BlockChainDeps<K,V>;
  
  public var head(default,null):StringMap<Hash>;

  public var data(default,null):StringMap<V>;
  public var refs(default,null):StringMapOfArrayOfEntry<K>;
  
  public function new(deps:BlockChainDeps<K,V>){
    this.serializer           = new Serializer();
    this.serializer.useCache  = true;
    
    this.refs                 = new StringMapOfArrayOfEntry();
    this.head                 = new StringMap();
    this.data                 = new StringMap();

    this.deps                 = deps;
  }
  private function get_master():Option<Hash>{
    return __.option(this.head.get("master"));
  }
  private function get_refs(?hash:Hash):Option<EntryArray<K>>{
    return 
      __.option(hash)
        .or(()->get_master())
        .flat_map(
          (hash) -> {
            var refs = this.refs.get(hash);
            ///trace(__.option(refs).map( x -> x.show()).defv(null));
            return __.option(refs);
          }
        );
  }
  function obtain(k:Articulation<K>):Array<Option<HashedArrayOfEntry<K>>>{
    return k.toIter().foldl(
      (key:K,memo:Array<Option<HashedArrayOfEntry<K>>>) -> {
        return memo.last().flat_map(x -> x).flat_map(
          ent -> (ent.snd()).search(
            (entry) -> entry.key == key
          ).flat_map(
            (entry) -> __.couple(Some(entry.points_to),get_refs(entry.points_to).defv([]))
          )
        ).map(
            (x:Couple<Option<Hash>,EntryArray<K>>) -> memo.snoc(Some(x))
        ).defv(memo.snoc(None));
      },
      [__.couple(get_master(),get_refs().defv([]))]
    );
  }
  /**
    [a, b, c] => "X"
    [a, b, d] => "Y"

    h = ['c',[hash("X")]]
    j = ['b',[hash(h)]]
    k = ['a',[hash(j)]]

    l = ['d',[hash("Y")]]
    m = ['b',[j,hash(l)]]
    n = ['a',[hash(m)]]
  **/
  public function set(k:Articulation<K>,v:V):Execute<DbFailure>{
    trace("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    var vhash       = Global.hash(v);
    trace('vhash: $vhash');
    this.data.set(vhash.prj(),v);
    var have        = obtain(k);
    trace('path: ${have.map(x -> x.map(y -> y.show()))}');
    var want        = k.zip(have);
    trace("__");
    var next        = want.rfold(
      (next:Couple<K,Option<HashedArrayOfEntry<K>>>,memo:Couple<Either<Hash,Hash>,Array<HashedArrayOfEntry<K>>>) -> {
        trace('-------------------------NEXT-------------------------');
        var is_duplicate_key = next.snd().defv(HashedArrayOfEntry.unit()).any(
          (e:Entry<K>) -> e.key == next.fst()
        );
        var branched    = memo.fst().is_left();
        trace('is_duplicate_key= ${next.fst()}? $is_duplicate_key, branched? $branched');
        var entry       = Entry.make(next.fst(),memo.fst().get_data());
        trace(entry.show());
        var n_src         = next.snd().defv(HashedArrayOfEntry.unit());
        trace('n_src: $n_src');
        var n_next        = is_duplicate_key.if_else(
          () ->  n_src.mod(
            (arr) -> arr.map(
              entryI -> (entryI.key == entry.key) ? entry : entryI
            )
          ),
          () -> n_src.snoc(entry).rehash()
        );
        trace('is: $n_src then $n_next');
        trace('to: ${memo.fst().get_data().truncate(5)} n_next: $n_next');
        var next_hash     = n_next.hash.fudge();
        trace('next_hash: ${next_hash.truncate(5)}');
        var n_hash        = (!is_duplicate_key) ? Left(next_hash) : Right(next_hash);
        
        //var n_memo_snd    = memo.snd().snoc(n_next);
        var n_memo        = __.couple(n_hash,memo.snd().cons(n_next));
        return n_memo;
      },
      __.couple(Left(vhash),[])
    );
    var first = next.fst().get_data();
    trace('________________set________________');

    for(x in next.snd()){
      __.log().close().trace(x);
      refs.set(x.fst().fudge(),x.snd());
    }
    trace('___________________________________');
    head.set('master',next.snd().head().flat_map( x -> x.fst()).fudge());

    return Execute.unit();
  } 
  public function get(k:Articulation<K>):Proceed<Option<V>,DbFailure>{
    trace("????????????????????????");
    var ls = obtain(k);
    for(x in ls){
      //trace(x);
    }
    var opt = ls.last().flat_map(x -> x).flat_map(x -> x.fst()).flat_map(
      (hash) -> __.option(data.get(hash.prj()))
    );
    trace(opt);
    return Proceed.pure(opt);
  }
  public function has(k:Articulation<K>):Proceed<Bool,DbFailure>{
    return null;
  }
  @:note("seems a bit heavy")
  public function itr():Proceed<Array<Articulation<K>>,DbFailure>{
    return Proceed.fromErr(__.fault().of(E_Db_Unimplemented));
  }
}