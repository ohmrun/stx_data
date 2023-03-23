package stx.assert.data.graph.comparable;

import stx.data.graph.Triplet as TTriplet;

class Triplet<Pi,Pii,Piii> implements ComparableApi<TTriplet<Pi,Pii,Piii>>{
  final subject   : Comparable<Pi>;
  final predicate : Comparable<Pii>;
  final object    : Comparable<Piii>;

  public function new(subject,predicate,object){
    this.subject    = subject;
    this.predicate  = predicate;
    this.object     = object;
  }
  public function eq():Eq<TTriplet<Pi,Pii,Piii>>{
    return Eq.Anon(
      (lhs:TTriplet<Pi,Pii,Piii>,rhs:TTriplet<Pi,Pii,Piii>) -> {
        var eq = this.subject.eq().comply(lhs.subject,rhs.subject);
        if(eq.is_equal()){
          eq = this.predicate.eq().comply(lhs.predicate,rhs.predicate);
        }
        if(eq.is_equal()){
          eq = this.object.eq().comply(lhs.object,rhs.object);
        }
        return eq;
      }
    );
  }
  public function lt():Ord<TTriplet<Pi,Pii,Piii>>{
    return Ord.Anon(
      (lhs:TTriplet<Pi,Pii,Piii>,rhs:TTriplet<Pi,Pii,Piii>) -> {
        var ord = this.subject.lt().comply(lhs.subject,rhs.subject);
        if(ord.is_not_less_than()){
          ord = this.predicate.lt().comply(lhs.predicate,rhs.predicate);
        }
        if(ord.is_not_less_than()){
          ord = this.object.lt().comply(lhs.object,rhs.object);
        }
        return ord;
      }
    );
  }
  public function toComparable(){
    return this;
  }
}