package stx.data;


#if (test=="stx_db")
class Test{
  static public function main(){
    trace("start");
    __.test([new TableSchemaTest()]);
  }
}
class TableSchemaTest extends haxe.unit.TestCase{
  public function test(){
    var name_type	 = Table.type.make('Name',Table.kind.chars());
		var email_type = Table.type.make("Email",Table.kind.chars());
		var user_type  = Table.schema.make(
			"User",
			[
				Table.col.make(0,'email',email_type)
			]
    );
    trace(user_type);
  }
}
#end