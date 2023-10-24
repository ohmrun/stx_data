package stx.data.store.block_chain;

import stx.data.store.block_chain.Entry;
import stx.data.store.block_chain.term.MemoryBlockChain;
import stx.data.store.settable_store.*;
import stx.data.store.block_chain.*;

class BlockChain<K,V>{
  static public function Memory<K,V>(deps):BlockChain<K,V>{
    return new MemoryBlockChain(deps);
  }
  #if (sys || nodejs)
  static public function FileSystem<K,V>(deps,device,directory):BlockChain<K,V>{
    return new sys.stx.data.store.block_chain.term.FileSystemBlockChain(deps,device,directory);
  }
  #end
  public var deps(default,null):BlockChainDeps<K,V>;
  
  public var head(default,null):SettableStoreApi<String,Hash>;
  public var data(default,null):SettableStoreApi<String,V>;

  public var refs(default,null):SettableStoreApi<String,ArrayOfEntry<K>>;
  
  public function new(
    deps:BlockChainDeps<K,V>,
    head:SettableStoreApi<String,Hash>,
    data:SettableStoreApi<String,V>,
    refs:SettableStoreApi<String,ArrayOfEntry<K>>
  ){
    
    this.deps                 = deps;

    this.head                 = head;
    this.data                 = data;
    this.refs                 = refs;
    
  }
  private function get_master():Propose<Hash,DataFailure>{
    var out = this.head.get("master").map(
      ((x:Hash) -> {}).fn().promote()
    );
    return out;
  }
  private function get_refs(?hash:Hash):Propose<ArrayOfEntry<K>,DataFailure>{
    return 
        Propose.make(hash)
        .or(()->get_master())
        .flat_map(
          (hash:Hash) -> {
            __.log().trace('hash: $hash');
            var refs = this.refs.get(hash.prj());
            //$type(refs);
            ///trace(__.option(refs).map( x -> x.show()).defv(null));
            return refs;
          }
        ).or(
          () -> Propose.fromChunk(Val([]))
        ).after(
          (x) -> {__.log().debug(_ -> _.pure(x.map(_ -> _.toString())));}
        );
  }
  private function obtain(k:Articulation<K>):Propose<Array<Option<HashedArrayOfEntry<K>>>,DataFailure>{
    ///trace('OBTAIN ${k.length}');
    return get_refs().materialise().and(get_master().materialise()).convert(
      (couple:Couple<Option<ArrayOfEntry<K>>,Option<Hash>>)-> {
        __.log().trace(_ -> _.pure(couple.fst().defv([])));
        return [Some(HashedArrayOfEntry.make(couple.snd(),couple.fst().defv([])))];
      }
    ).flat_map(
      (seed:Array<Option<HashedArrayOfEntry<K>>>) -> Propose.bind_fold(
        (key:K,memo:Array<Option<HashedArrayOfEntry<K>>>) -> {
          var last = memo.last().flat_map(x -> x);
          //trace(last.map(x -> x.tup()));
          return Propose.fromOption(last).flat_map(
            (ent:HashedArrayOfEntry<K>) -> {
              //trace(ent);
              return Propose.fromOption(ent.snd().search((entry) -> entry.key == key)).flat_map(
                (entry:Entry<K>) -> get_refs(entry.points_to).diffuse(
                  Diffuse.fromOptionIR((refs:Option<ArrayOfEntry<K>>) -> __.couple(Some(entry.points_to),refs.defv(ArrayOfEntry.unit())))
                )
              );
            }
          ).diffuse(
              Diffuse.fromOptionIR(
                (opt:Option<Couple<Option<Hash>,ArrayOfEntry<K>>>) -> memo.snoc(opt)
              )
          );
        },
        k,
        seed
      )
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
  public function set(k:Articulation<K>,v:V):Execute<DataFailure>{
    //trace("!!!!!!!!!!!!!!SET!!!!!!!!!!!!!!!!");
    var vhash       = Global.hash(v);
    //trace('vhash: $vhash');

    return this.data.set(vhash.prj(),v).execute(
      Execute.fromFunXExecute(
        () -> obtain(k).command(
          Command.fromFun1Execute(
            (have:Array<Option<HashedArrayOfEntry<K>>>) -> {
              __.log().trace('path: ${have.map(x -> x.map(y -> y.show()))}');
              var want        = k.zip(have);
              //trace("__");
              var next        = want.rfold(
                (next:Couple<K,Option<HashedArrayOfEntry<K>>>,memo:Couple<Either<Hash,Hash>,Array<HashedArrayOfEntry<K>>>) -> {
                  //trace('-------------------------NEXT-------------------------');
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
                  //trace('is: $n_src then $n_next');
                  //trace('to: ${memo.fst().get_data().truncate(5)} n_next: $n_next');
                  if(!n_next.hash.is_defined()){
                    n_next = n_next.rehash();
                  }
                  var next_hash     = n_next.hash.fudge();
                  //trace('next_hash: ${next_hash.truncate(5)}');
                  var n_hash        = (!is_duplicate_key) ? Left(next_hash) : Right(next_hash);
                  
                  //var n_memo_snd    = memo.snd().snoc(n_next);
                  var n_memo        = __.couple(n_hash,memo.snd().cons(n_next));
                  return n_memo;
                },
                __.couple(Left(vhash),[])
              );
              //var first = next.fst().either().get_data();
              //trace('________________PUT________________');

              //$type(next.snd());
              var ex = Execute.sequence(
                (x:HashedArrayOfEntry<K>) -> {
                  //trace(x.show());
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
  public function get(k:Articulation<K>):Propose<V,DataFailure>{
    //trace('???????????$k?????????????');
    return obtain(k).flat_map(
      (ls) -> {
        //for(x in ls){
          //trace(x);
        //}
        var opt = ls.last().flat_map(x -> x).flat_map(x -> x.fst()).flat_map(
          (hash) -> data.get(hash.prj())
        ).defv(Propose.unit());
        //$type(opt);
        return opt;
      }
    );
  }
  public function has(k:Articulation<K>):Produce<Bool,DataFailure>{
    return null;
  }
  @:note("seems a bit heavy")
  public function itr():Produce<Cluster<Articulation<K>>,DataFailure>{
    return Produce.fromRefuse(__.fault().of(E_Db_Unimplemented));
  }
}
class BlockChainHelp{
  
}