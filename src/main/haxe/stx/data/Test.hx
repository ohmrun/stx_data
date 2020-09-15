package stx.data;

/**
  The last key points to the hash of value V
  The before keys point to hashes of arrays of....
**/


class Test{
  static public function main(){
    __.test([new FirstTest()]); 
  }
}
typedef HasHashable = {
  public function hashable():Any;
}

class Global{
  static public function hash<T>(v:T):Hash{
    return Helper.hash(
      { 
        hashable : () -> (v:Any)
      }
    );
  }
}
@:forward abstract References<K>(StringMap<ArrayOfEntry<K>>){
  public function new() this = new StringMap();
  public function get(hash:Hash):ArrayOfEntry<K>{
    return this.get(hash.prj());
  }
  public function set(hash:Hash,data:ArrayOfEntry<K>){
    this.set(hash.prj(),data);
  }
}

@:forward abstract ArrayOfEntry<K>(EntryArray<K>) from EntryArray<K> to EntryArray<K>{
  public function toString(){
    return this.map(
      (entry) -> entry.toString()
    );
  }
}

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
@:forward abstract EntryArray<K>(Array<Entry<K>>) from Array<Entry<K>> to Array<Entry<K>>{
  public function new(self) this = self;

  public function hashable():Any{
    return this.map( entry -> entry.hashable() );
  }
  public function show(){
    var a = this.map( entry -> entry.show() ).join(",");
    return '[$a]';
  }
  @:noUsing static public function pure<K>(entry:Entry<K>):EntryArray<K>{
    return new EntryArray([entry]);
  }
  public function toString(){
    return show();
  }
  @:to public function asHashable():HasHashable{
    return {
      hashable : hashable
    };
  }
  private var self(get,never):EntryArray<K>;
  private function get_self():EntryArray<K> return this;
}
@:forward abstract HashedArrayOfEntry<K>(Couple<Option<Hash>,EntryArray<K>>) from Couple<Option<Hash>,EntryArray<K>>{
  public function new(self) this = self;
  @:noUsing static public function unit<K>():HashedArrayOfEntry<K>{
    return make(None,[]);
  }
  @:noUsing static public function make<K>(hash:Option<Hash>,array:EntryArray<K>){
    return new HashedArrayOfEntry(__.couple(hash,array));
  }
  @:noUsing static public function pure<K>(entry:Entry<K>){
    var arr   = EntryArray.pure(entry);
    var hash  = Helper.hash(arr);
    return make(Some(hash),arr);
  }
  public function mod(fn:EntryArray<K>->EntryArray<K>):HashedArrayOfEntry<K>{
    return make(this.fst(),fn(this.snd()));
  }
  public function rehash(){
    return make(Helper.hash(this.snd()),this.snd());
  }
  public var hash(get,never):Option<Hash>;
  private function get_hash():Option<Hash>{
    return this.fst();
  }
  public var data(get,never):EntryArray<K>;
  private function get_data():EntryArray<K>{
    return this.snd();
  }
  public function hashable():Any{
    return this.map(
      arr -> arr.hashable()
    ).tup();
  }
  public function show(){
    var l = this.fst().map(x -> x.truncate(5));
    var r = this.snd().show();
    return '($l::$r)';
  }
  public function toString(){
    return show();
  }
  public function snoc(item:Entry<K>){
    return make(this.fst(),this.snd().snoc(item));
  }
  public function any(fn:Entry<K>->Bool){
    return this.snd().any(fn);
  }
  @:to public function asHashable():HasHashable{
    return {
      hashable : hashable
    }
  }
}

class BlockStoreOne<K,V>{
  private var serializer : Serializer;

  public var deps(default,null):BlockStoreOneDeps<K,V>;
  
  public var head(default,null):StringMap<Hash>;

  public var data(default,null):StringMap<V>;
  public var refs(default,null):References<K>;
  
  public function new(deps:BlockStoreOneDeps<K,V>){
    this.serializer           = new Serializer();
    this.serializer.useCache  = true;
    
    this.refs                 = new References();
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
class FirstTest extends haxe.unit.TestCase{
  public function test(){
    var a = Articulation.lift(["a","b","c"]);
    var b = {
      value : true
    };
    var d = {
      value : false
    };
    var store = new BlockStoreOne(BlockStoreOneDeps.unit());
    __.log()('OK: $a');
        store.set(a,b);
    var c = Articulation.lift(["a","b","d","e"]);
    __.log()('OK: $c');
        store.set(c,d);
    __.log()('GET: $a');
    var e = store.get(a);
    trace(e);
    __.log()('GET: $c');

    __.log()('OK: $a');
    store.set(a,d);
    __.log()('GET: $a');
    var f = store.get(c);
    var g = store.get(a);
    __.log()('GET: $c');
    var h = store.get(c);

    var i = Articulation.lift(["m"]);
    store.set(i,b);
    __.log()('GET: $i');
    var j = store.get(i);
  }
}
class TableSchemaTest{
  public function _test(){
    var name_type	 = Table.type.make('Name',Table.kind.chars());
		var email_type = Table.type.make("Email",Table.kind.chars());
		var user_type  = Table.schema.make(
			"User",
			[
				Table.col.make(0,'email',email_type)
			]
		);
  }
}

interface TypeWrapper<T>{
  public function toSourceString():String;
  public function fromSourceString(str:String):T;
}

interface Notifier<K,V>{
  public function notify(key:K,val:Option<V>):Void;
}
@:allow(stx.data) abstract Hash(String){
  @:noUsing static public function make(self:String):Hash{
    return new Hash(self);
  }
  private function new(self) this = self;
  private function prj():String return this;

  public function truncate(int){
    return this.toChars().truncate(int);
  }
}
class Helper{
  @:noUsing static public function hash<T:HasHashable>(v:T):Hash{
    return new Hash(Sha1.encode(Serializer.run(v.hashable())));
  }
}
@:forward abstract Entry<K>(Couple<K,Hash>){
  static public function make<K>(k:K,v:Hash):Entry<K>{
    return new Entry(__.couple(k,v));
  }
  public function new(self) this = self;
  public function prj():Couple<K,Hash> return this;

  public var self(get,never):Entry<K>;
  private function get_self():Entry<K> return new Entry(this);

 
  public var key(get,never):K;
  private function get_key():K{
    return this.fst();
  }
  public var points_to(get,never):Hash;
  private function get_points_to():Hash{
    return this.snd();
  }
  public function show(){
    var l = this.fst();
    var r = this.snd().truncate(5);
    return 'Entry($l->$r)';
  }
  public function hashable(){
    return this.tup();
  }
  @:to public function asHashable(){
    return { hashable : hashable };
  }
}
@:forward abstract HashedEntry<K>(Couple<Option<Hash>,Entry<K>>){
  public function new(self) this = self;

  public var entry(get,never):Entry<K>;
  private function get_entry():Entry<K>{
    return this.snd();
  }
  public var hash(get,never):Option<Hash>;
  private function get_hash():Option<Hash>{
    return this.fst();
  }

  public function toHashedArrayOfEntry(){
    return HashedArrayOfEntry.make(this.fst(),[this.snd()]);
  }
  public function hashable(){
    return this.map(x -> x.hashable()).tup();
  }
  public function show(){
    var l = this.fst().map(x -> x.truncate(5)).defv("?");
    var r = this.snd().show();
    return '#($l:$r)';
  }
  inline public function toString(){
    return show();
  }
}
@:forward abstract Indexes<K>(Array<HashedEntry<K>>) from Array<HashedEntry<K>> to Array<HashedEntry<K>>{
  
}
@:forward abstract HashedStoreVal<K,V>(Couple<Hash,StoreVal<K,V>>){
  static public function make(hash,node){
    return new HashedStoreVal(__.couple(hash,node));
  }
  public function new(self) this = self;
  public var hash(get,never):Hash;
  private function get_hash():Hash{
    return this.fst();
  }
}
typedef BlockStoreOneDepsDef<K,V> = {
  K : { 
    hash : K -> String,
    eq   : K -> K -> Bool
  },
  V : { 
    hash : V -> String
  }
};
@:forward abstract BlockStoreOneDeps<K,V>(BlockStoreOneDepsDef<K,V>) from BlockStoreOneDepsDef<K,V>{
  public function new(self) this = self;
  static public function form<K,V>():BlockStoreOneDepsDef<K,V>{
    var serializer = new Serializer();
        serializer.useCache = true;
    return {
      K : {
        hash : (k:K) -> {
          serializer.serialize(k);
          return Sha1.encode(serializer.toString());
        },
        eq : (l,r) -> l == r
      },
      V : {
        hash : (v:V) -> {
          serializer.serialize(v);
          return Sha1.encode(serializer.toString());
        }
      }
    };
  }
  static public function unit<K,V>():BlockStoreOneDeps<K,V>{
    return form();
  } 
}