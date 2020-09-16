package stx.data.store;

import stx.data.store.settable_store.*;
import stx.data.store.block_chain.*;

class BlockChain<K,V>{
  private var serializer : Serializer;

  public var deps(default,null):BlockChainDeps<K,V>;
  
  public var head(default,null):SettableStoreApi<String,Hash>;
  public var data(default,null):SettableStoreApi<String,V>;

  public var refs(default,null):SettableStoreApi<String,ArrayOfEntry<K>>;
  
  public function new(deps:BlockChainDeps<K,V>){
    this.serializer           = new Serializer();
    this.serializer.useCache  = true;
    
    this.refs                 = new MemorySettableStoreOfString();
    this.head                 = new MemorySettableStoreOfString();
    this.data                 = new MemorySettableStoreOfString();

    this.deps                 = deps;
  }
  private function get_master():Provide<Hash,DbFailure>{
    var out = this.head.get("master").postfix(
      __.passthrough(
        (x:Hash) -> trace('get_master: $x')
      )
    );
    return out;
  }
  private function get_refs(?hash:Hash):Provide<ArrayOfEntry<K>,DbFailure>{
    return 
        Provide.make(hash)
        .or(()->get_master())
        .flat_map(
          (hash:Hash) -> {
            trace('hash: $hash');
            var refs = this.refs.get(hash.prj());
            //$type(refs);
            ///trace(__.option(refs).map( x -> x.show()).defv(null));
            return refs;
          }
        ).or(
          () -> Provide.fromChunk(Val([]))
        );
  }
  function obtain(k:Articulation<K>):Provide<Array<Option<HashedArrayOfEntry<K>>>,DbFailure>{
    trace('OBTAIN');
    return get_refs().materialise().postfix(__.logger()).and(get_master().materialise()).process(
      (couple:Couple<Option<ArrayOfEntry<K>>,Option<Hash>>)-> {
        trace(couple.fst().defv([]));
        return [Some(HashedArrayOfEntry.make(couple.snd(),couple.fst().defv([])))];
      }
    ).flat_map(
      (seed:Array<Option<HashedArrayOfEntry<K>>>) -> Provide.bind_fold(
        (key:K,memo:Array<Option<HashedArrayOfEntry<K>>>) -> {
          var last = memo.last().flat_map(x -> x);
          trace(last);
          return Provide.fromOption(last).flat_map(
            (ent:HashedArrayOfEntry<K>) -> {
              trace(ent);
              return Provide.fromOption(ent.snd().search((entry) -> entry.key == key)).flat_map(
                (entry:Entry<K>) -> get_refs(entry.points_to).exudate(
                  Exudate.fromOptionIR((refs:Option<ArrayOfEntry<K>>) -> __.couple(Some(entry.points_to),refs.defv(ArrayOfEntry.unit())))
                )
              );
            }
          ).exudate(
              Exudate.fromOptionIR(
                (opt:Option<Couple<Option<Hash>,ArrayOfEntry<K>>>) -> memo.snoc(__.logger()(opt))
              )
          );
        },
        k,
        seed
      ).defv(Provide.pure([]))
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
    trace("!!!!!!!!!!!!!!SET!!!!!!!!!!!!!!!!");
    var vhash       = Global.hash(v);
    trace('vhash: $vhash');

    return this.data.set(vhash.prj(),v).execute(
      Execute.fromFunXExecute(
        () -> obtain(k).command(
          Command.fromFun1Execute(
            (have:Array<Option<HashedArrayOfEntry<K>>>) -> {
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
                  //trace('is_duplicate_key= ${next.fst()}? $is_duplicate_key, branched? $branched');
                  var entry       = Entry.make(next.fst(),memo.fst().get_data());
                  //trace(entry.show());
                  var n_src         = next.snd().defv(HashedArrayOfEntry.unit());
                  //trace('n_src: $n_src');
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
                  if(!n_next.hash.is_defined()){
                    n_next = n_next.rehash();
                  }
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
              trace('________________PUT________________');

              $type(next.snd());
              var ex = Execute.sequence(
                (x:HashedArrayOfEntry<K>) -> {
                  __.log().trace(x.show());
                  return refs.set(x.fst().fudge().prj(),x.snd());
                },
                next.snd()
              ).execute(
                () -> head.set('master',next.snd().head().flat_map( x -> x.fst()).fudge())
              );              
              return ex;
            }
          )
        )
      )
    );
  } 
  public function get(k:Articulation<K>):Provide<V,DbFailure>{
    trace('???????????$k?????????????');
    return obtain(k).flat_map(
      (ls) -> {
        for(x in ls){
          //trace(x);
        }
        var opt = ls.last().flat_map(x -> x).flat_map(x -> x.fst()).flat_map(
          (hash) -> data.get(__.logger()(hash).prj())
        ).defv(Provide.unit());
        $type(opt);
        return opt;
      }
    );
  }
  public function has(k:Articulation<K>):Proceed<Bool,DbFailure>{
    return null;
  }
  @:note("seems a bit heavy")
  public function itr():Proceed<Array<Articulation<K>>,DbFailure>{
    return Proceed.fromErr(__.fault().of(E_Db_Unimplemented));
  }
}