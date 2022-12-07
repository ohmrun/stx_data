package stx.assert.data.graph.eq;

import stx.data.graph.Triplet as TTriplet;

class Triplet<Pi,Pii,Piii> extends EqCls<TTriplet<Pi,Pii,Piii>>{
  final subject   : Eq<Pi>;
  final predicate : Eq<Pii>;
  final object    : Eq<Piii>;

  public function new(subject:Eq<Pi>,predicate:Eq<Pii>,object:Eq<Piii>){
    this.subject    = subject;
    this.predicate  = predicate;
    this.object     = object;
  }
  public function comply(lhs:TTriplet<Pi,Pii,Piii>,rhs:TTriplet<Pi,Pii,Piii>):Equaled{
    var eq = this.subject.comply(lhs.subject,rhs.subject);
    if(eq.is_equal()){
      eq = this.predicate.comply(lhs.predicate,rhs.predicate);
    }  
    if(eq.is_equal()){
      eq = this.object.comply(lhs.object,rhs.object);
    }  
    return eq;
  }
}