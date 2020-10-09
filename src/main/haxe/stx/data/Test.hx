package stx.data;


using stx.ASys;

#if (test=="stx_db")
class Test{
  static public function main(){
    trace("start");
    __.test([new FirstTest()]); 
  }
}

class FirstTest extends haxe.unit.TestCase{
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
    __.log()('OK: $keyI _________________________________________1');
    var _a    = store.set(keyI,valI);
    var _b    = _a.execute(
      () -> {
        __.log()('OK: $keyII __________________________________2');
        return store.set(keyII,valII);
      }
    );
    $type(_b);
    var _c    = _b.propose(
      $type(store.get(keyI).before(
        ()-> {
          __.log()('GET: $keyI _____________________________________3');
        }
      ))
    );
    var _d  = _c.command(
        (chunk) -> {
          trace(chunk);
          return Report.unit();
        }
    );
    var _e = _d.execute(
      () -> store.get(keyII).command((chunk) -> {
        trace(chunk);
        return Report.unit();
      })
    );
    var _f = _e.execute(
      () -> store.set(keyI,valII)
    ).execute(
      () -> store.get(keyI).command(
        x -> trace(x)
      )
    );
    var _g = _f.execute(
      () -> store.set(keyIII,valI)
    ).execute(
      () -> store.get(keyIII).command(
        (x) -> trace(x)
      ).execute(
        () -> store.get(keyI).command(
          x -> trace(x)
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
      env.device.shell.cwd.pop().provide(env).crack().fudge().down("DATA")
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
#end