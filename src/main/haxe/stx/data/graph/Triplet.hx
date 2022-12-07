package stx.data.graph;

typedef TripletDef<Pi,Pii,Piii> = {
  final subject     : Pi;
  final predicate   : Pii;
  final object      : Piii;
}
@:using(stx.data.graph.Triplet.TripletLift)
@:forward abstract Triplet<Pi,Pii,Piii>(TripletDef<Pi,Pii,Piii>) from TripletDef<Pi,Pii,Piii> to TripletDef<Pi,Pii,Piii>{
  static public var _(default,never) = TripletLift;
  public inline function new(self:TripletDef<Pi,Pii,Piii>) this = self;
  @:noUsing static inline public function lift<Pi,Pii,Piii>(self:TripletDef<Pi,Pii,Piii>):Triplet<Pi,Pii,Piii> return new Triplet(self);

  public function prj():TripletDef<Pi,Pii,Piii> return this;
  private var self(get,never):Triplet<Pi,Pii,Piii>;
  private function get_self():Triplet<Pi,Pii,Piii> return lift(this);
}
class TripletLift{
  static public inline function lift<Pi,Pii,Piii>(self:TripletDef<Pi,Pii,Piii>):Triplet<Pi,Pii,Piii>{
    return Triplet.lift(self);
  }
}