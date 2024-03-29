package sys.stx.data.store.block_chain.term;


#if (sys || nodejs)
using stx.fs.Path;
#end

#if (sys || nodejs)
import sys.stx.data.store.settable_store.SyncFileSystemSettableStoreOfString;

class FileSystemBlockChain<K,V> extends BlockChain<K,V>{
  public var device(default,null):DeviceApi;
  public var directory(default,null):Directory;

  public function new(deps:BlockChainDeps<K,V>,device,directory){
    this.device     = device;
    this.directory  = directory;

    var head       = new SyncFileSystemSettableStoreOfString({
      V : {
        serialize   : (hash:Hash)   -> {
          return Serialize.encode(@:privateAccess hash.prj());
        },
        unserialize : (str:String)  -> {
          return @:privateAccess new Hash(Serialize.decode(str));
        },
        hash        : (hash:Hash)   -> hash
      }
    },device,directory.down("head"));
    var data       = new SyncFileSystemSettableStoreOfString({
      V : {
        serialize   : (data:V)      -> deps.V.serialize(data),
        unserialize : (str:String)  -> deps.V.unserialize(str),
        hash        : deps.V.hash
      }
    },device,directory.down("data"));
    var refs       = new SyncFileSystemSettableStoreOfString({
      V : {
        serialize   : (arr:ArrayOfEntry<K>)            -> {
          var data    = arr.serializable();
          //trace(data);
          var result  = Serialize.encode(data);
          //trace(result);
          return result;
        },
        unserialize : (str:String)                      -> {
          var data : Array<Tup2<K,Hash>> = Serialize.decode(str);
          //trace(data);
          var make = data.map(
            (tp:Tup2<K,Hash>) -> switch(tp){
              case tuple2(l,r) : new stx.data.store.block_chain.Entry(__.couple(l,r));
            }
          );
          return (make:ArrayOfEntry<K>);
        },
        hash        : (v:ArrayOfEntry<K>)               -> Hash.pure(v)
      }
    },device,directory.down("refs"));

    super(deps,head,data,refs);
  }
}
#end