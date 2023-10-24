package sys.stx.data.store.settable_store;

#if (sys || nodejs)
import sys.io.File;
import stx.asys.DeviceApi;
using stx.fs.Path;
import sys.FileSystem;
#end



import stx.data.store.block_chain.Hash;

#if (sys || nodejs)
class SyncFileSystemSettableStoreOfString<V> implements stx.data.store.SettableStoreApi<String,V>{

  public var deps(default,null):{
    V : {
      serialize   : V -> String,
      unserialize : String -> V,
      hash        : V -> Hash
    }
  };
  public var device(default,null):DeviceApi;
  public var directory(default,null):Directory;

  public function new(deps,device,directory){
    this.deps                 = deps;
    this.device               = device;
    this.directory            = directory;

    var path = this.directory.canonical(this.device.sep);
    if(!FileSystem.exists(path)){
      FileSystem.createDirectory(path);
    }
  }
  public function set(k:String,v:V):Execute<DataFailure>{
    //trace('SET $k $v');
    var data      = deps.V.serialize(v);
    var path      = this.directory.entry(k).canonical(this.device.sep);
    File.saveContent(path,data);
    return Execute.unit();
  }
  public function get(k:String):Propose<V,DataFailure>{
    var path          = this.directory.entry(k).canonical(this.device.sep);
    return if(!FileSystem.exists(path)){
      Propose.fromChunk(Tap);
    }else{
      var content       = File.getContent(path);
      //trace(content);
      var reconstructed = deps.V.unserialize(content);
      //trace(reconstructed);
      Propose.pure(reconstructed);
    } 
  }
  public function has(k:String):Produce<Bool,DataFailure>{
    var out = FileSystem.exists(this.directory.entry(k).canonical(this.device.sep));
    return Produce.pure(out);
  }
  public function itr():Produce<Cluster<String>,DataFailure>{
    var paths = FileSystem.readDirectory(this.directory.canonical(this.device.sep));
    return Produce.pure(paths);
  }
  public function del(k:String){
    var path      = this.directory.entry(k).canonical(this.device.sep);
    sys.FileSystem.deleteFile(path);
    return Execute.unit();
  }
}
#end