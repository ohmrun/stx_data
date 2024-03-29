package stx.data;

enum TableFailure{

}
class Table{
  static public var type(default,null)  	= {
		make : TableDataType.make
	};
	static public var kind(default,null)   	= {
		bool 	: TableDataKind.bool,
		int 	: TableDataKind.int,
		float	: TableDataKind.float,
		chars	: TableDataKind.chars
	}
	static public var col(default,null)		 	= {
		make : ColumnDefinition.make
	}
	static public var schema(default,null)	= {
		make : TableSchema.make
	}
}
typedef TableForeignKey = {
	var type 		: TableDataType;
	var field 	: String;
}
typedef TableDataTypeDef = {
	public var name(default,null):String;
	public var kind(default,null):TableDataKind;
}
@:forward abstract TableDataType(TableDataTypeDef) from TableDataTypeDef to TableDataTypeDef{
	public function new(self) this = self;
	@:noUsing static public function lift(self:TableDataTypeDef):TableDataType return new TableDataType(self);
	@:noUsing static public function make(name,kind):TableDataType{
		return { name : name, kind : kind };
	}
	public function prj():TableDataTypeDef return this;
	private var self(get,never):TableDataType;
	private function get_self():TableDataType return lift(this);
}
enum TableDataKindSum{
	TDK_Prim(v:PrimitiveTypeSum);
	TDK_Link(v:TableForeignKey);
}
@:forward abstract TableDataKind(TableDataKindSum) from TableDataKindSum to TableDataKindSum{
	public function new(self) this = self;
	@:noUsing static public function lift(self:TableDataKindSum):TableDataKind 	return new TableDataKind(self);

	@:noUsing static public function PTBool():TableDataKind 					return TDK_Prim(PrimitiveTypeSum.PTBool);
	@:noUsing static public function bool():TableDataKind 						return TDK_Prim(PrimitiveTypeSum.PTBool);

	@:noUsing static public function PTInt():TableDataKind 						return TDK_Prim(PrimitiveTypeSum.PTInt);
	@:noUsing static public function int():TableDataKind 							return TDK_Prim(PrimitiveTypeSum.PTInt);
	
	@:noUsing static public function PTFloat():TableDataKind 					return TDK_Prim(PrimitiveTypeSum.PTFloat);
	@:noUsing static public function float():TableDataKind 						return TDK_Prim(PrimitiveTypeSum.PTFloat);

	@:noUsing static public function PTText():TableDataKind 					return TDK_Prim(PrimitiveTypeSum.PTText);
	@:noUsing static public function chars():TableDataKind 						return TDK_Prim(PrimitiveTypeSum.PTText);

	@:noUsing static public function PTBlob():TableDataKind 					return TDK_Prim(PrimitiveTypeSum.PTBlob);
	@:noUsing static public function blob():TableDataKind 						return TDK_Prim(PrimitiveTypeSum.PTBlob);
	

	public function prj():TableDataKindSum return this;
	private var self(get,never):TableDataKind;
	private function get_self():TableDataKind return lift(this);
}
typedef ColumnDefinitionDef = {
	public var idx(default,null):Int;//Want to be explicit about this.
	public var key(default,null):String;

	public var type(default,null):TableDataType;
}
@:forward abstract ColumnDefinition(ColumnDefinitionDef) from ColumnDefinitionDef to ColumnDefinitionDef{
	public function new(self) this = self;
	@:noUsing static public function lift(self:ColumnDefinitionDef):ColumnDefinition return new ColumnDefinition(self);
	@:noUsing static public function make(idx,key,type):ColumnDefinition{
		return { 
			idx 	: idx,
			key 	: key,
			type 	: type
		};
	}

	public function prj():ColumnDefinitionDef return this;
	private var self(get,never):ColumnDefinition;
	private function get_self():ColumnDefinition return lift(this);
}
typedef TableSchemaDef = {
	var name(default,null) 		: String; 
	var fields(default,null) 	: Array<ColumnDefinition>;
}
@:forward abstract TableSchema(TableSchemaDef) from TableSchemaDef to TableSchemaDef{
	public function new(self) this = self;
	@:noUsing static public function lift(self:TableSchemaDef):TableSchema return new TableSchema(self);
	@:noUsing static public function make(name:String,fields:Array<ColumnDefinition>){
		return { name : name,  fields : fields };
	}
	

	public function prj():TableSchemaDef return this;
	private var self(get,never):TableSchema;
	private function get_self():TableSchema return lift(this);
}
typedef ReadRowDef = {
  public function at(i:Int):Null<Blob>;
  public function iterator():Iterator<Blob>;
}
interface ReadRowApi {
  public function at(i:Int):Null<Blob>;
  public function iterator():Iterator<Blob>;
}
abstract ReadRow(ReadRowDef) from ReadRowDef {
	@:from static public function fromArray(arr:Array<Blob>):ReadRow{
		return{
      at        : (i:Int) -> arr[i],
      iterator  : arr.iterator
		};
	}
}
interface TableReadApi{
	var type(default,null)		: TableSchemaDef;
	public function pull(num:Int):ReadRow;
}
typedef TableReadDef = {
	var type(default,null)		: TableSchemaDef;
	public function pull(num:Int):ReadRow;
}
interface TableEditApi{
	public var type(default,null):TableSchemaDef;

	/**
		-1 means after the end of the list.
	**/
	public function insert(before:Int = -1,data:ReadRow):Execute<DataFailure>;
	public function update(index:Int,data:ReadRow):Execute<DataFailure>;
	public function delete(index:Int):Execute<DataFailure>;
}
typedef TableSchemataDef = Array<TableDataType>;
abstract TableSchemata(TableSchemataDef) from TableSchemataDef to TableSchemataDef{
	@:noUsing static public function lift<T>(self:TableSchemataDef) return new TableSchemata(self);
	public function new(self:TableSchemataDef) this = self;
}
class SignatureLift{
	// static public function validate<T>(self:Signature<T>,schemata:TableSchemata,inner:T->Report<TableFailure>){
	// 	return switch [self.prj()] {
	// 	case SigCollate(arr)	:
	// 		case SigPrimate(s)		:
	// 		case SigCollect(fn)		:
	// 		case SigPredate(v)		:
	// 		case SigUnknown				:
	// 	}
	// }	
}