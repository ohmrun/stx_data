package stx.data;

class Test{
  static public function main(){
    __.test([new FirstTest()]); 
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
    var store = new BlockChain(BlockChainDeps.unit());
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