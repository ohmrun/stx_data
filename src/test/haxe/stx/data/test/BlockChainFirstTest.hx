package stx.data.test;

using stx.ASys;
using stx.data.test.BlockChainFirstTest;

class BlockChainFirstTest extends haxe.unit.TestCase{
  static public function log(wildcard:Wildcard){
    return new stx.Log().tag("stx.data.test.BlockChainFirstTest");
  }
  public function _test(){ 
    var keyI    = Articulation.lift(["a","b","c"]);
    var keyII   = Articulation.lift(["a","b","d","e"]);
    var keyIII  = Articulation.lift(["m"]);
    var valI = {
      value : true
    };
    var valII = {
      value : false
    };

    var store = BlockChain.Memory(BlockChainDeps.unit());
    __.log().trace('OK: $keyI _________________________________________1');
    var _a    = store.set(keyI,valI);
    var _b    = _a.execute(
      () -> {
        __.log().trace('OK: $keyII __________________________________2');
        return store.set(keyII,valII);
      }
    );
    var _c    = _b.propose(
      store.get(keyI).before(
        ()-> {
          __.log().trace('GET: $keyI _____________________________________3');
        }
      )
    );
    var _d  = _c.command(
        __.command((chunk) -> {
          trace(chunk);
          return Report.unit();
        })
    );
    var _e = _d.execute(
      () -> store.get(keyII).command(__.command((chunk) -> {
        trace(chunk);
        return Report.unit();
      }))
    );
    var _f = _e.execute(
      () -> store.set(keyI,valII)
    ).execute(
      () -> store.get(keyI).command(
        __.command(x -> trace(x))
      )
    );
    var _g = _f.execute(
      () -> store.set(keyIII,valI)
    ).execute(
      () -> store.get(keyIII).command(
        __.command((x) -> trace(x))
      ).execute(
        () -> store.get(keyI).command(
          __.command(x -> trace(x))
        )
      )
    );
    _g.environment(
      () -> {},
      __.crack
    ).crunch();
  }
  function fs_store(){
    var env = __.asys().local();
    return new stx.data.store.block_chain.term.FileSystemBlockChain(
      BlockChainDeps.unit(),
      env.device,
      env.device.shell.cwd.pop().provide(env).fudge().down("DATA")
    );
  }
  public function test_filesystem(){
    __.log().trace("test filesystem");
    var a = fs_store();
    a.set(["a","b","C"],"hello").environment(
      () -> {},
      __.crack
    ).crunch();
  }
  public function test_get_filesystem(){
    __.log().trace("test get filesystem");
    var a = fs_store();
    a.get(["a","b","C"]).environment(
      (x) -> trace(x),
      __.crack
    ).crunch();
  }
}