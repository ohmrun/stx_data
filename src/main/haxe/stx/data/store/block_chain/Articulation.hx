package stx.data.store.block_chain;

typedef ArticulationDef<K> = Array<K>;

@:forward abstract Articulation<K>(ArticulationDef<K>) from ArticulationDef<K> to ArticulationDef<K>{
  public function new(self) this = self;
  @:noUsing static public function lift<K>(self:ArticulationDef<K>):Articulation<K> return new Articulation(self);
  
  public function last():Option<K>{
    return this.last();
  }
  public function iterator(){
    return this.iterator();
  }
  public function toIter():Iter<K>{
    return this;
  }

  public function prj():ArticulationDef<K> return this;
  private var self(get,never):Articulation<K>;
  private function get_self():Articulation<K> return lift(this);
}