package stx.data.store.block_chain;


@:allow(stx.data) abstract Hash(String){
  @:noUsing static public function make(self:String):Hash{
    return new Hash(self);
  }
  private function new(self) this = self;
  private function prj():String return this;

  public function truncate(int){
    return Chars.lift(this).truncate(int);
  }
}