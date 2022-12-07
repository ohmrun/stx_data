package stx.assert.data.graph.ord;

import stx.data.graph.Triplet as TTriplet;

class Triplet<Pi,Pii,Piii> extends OrdCls<TTriplet<Pi,Pii,Piii>>{
  final subject   : Ord<Pi>;
  final predicate : Ord<Pii>;
  final object    : Ord<Piii>;

  public function new(subject,predicate,object){
    this.subject    = subject;
    this.predicate  = predicate;
    this.object     = object;
  }
  public function comply(lhs:TTriplet<Pi,Pii,Piii>,rhs:TTriplet<Pi,Pii,Piii>){
    var ord = this.subject.comply(lhs.subject,rhs.subject);
    if(ord.is_not_less_than()){
      ord = this.predicate.comply(lhs.predicate,rhs.predicate);
    }  
    if(ord.is_not_less_than()){
      ord = this.object.comply(lhs.object,rhs.object);
    }  
    return ord;
  }
}