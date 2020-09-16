package stx.data;

class Test{
  static public function main(){
    __.test([new FirstTest()]); 
  }
}

class FirstTest extends haxe.unit.TestCase{
  public function test(){
    var keyI    = Articulation.lift(["a","b","c"]);
    var keyII   = Articulation.lift(["a","b","d","e"]);
    var keyIII  = Articulation.lift(["m"]);
    var valI = {
      value : true
    };
    var valII = {
      value : false
    };

    var store = new BlockChain(BlockChainDeps.unit());
    __.log()('OK: $keyI _________________________________________1');
    var _a    = store.set(keyI,valI);
    var _b    = _a.execute(
      () -> {
        __.log()('OK: $keyII __________________________________2');
        return store.set(keyII,valII);
      }
    );
    $type(_b);
    var _c    = _b.provide(
      store.get(keyI).before(
        ()-> {
          __.log()('GET: $keyI _____________________________________3');
        }
      )
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