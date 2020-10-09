package stx.db;

@:callable @:forward abstract Log(stx.Log){
  static public function log(wildcard:Wildcard){
    return new stx.db.Log();
  }
  public function new(){
    this = stx.Log.ZERO.tag("stx.db");
  }
}