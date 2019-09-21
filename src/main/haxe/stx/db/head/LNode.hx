package stx.db.head;

enum LNode{
    Choice(str:String,?ord:Int);
    Offset(int:Int);
    //Block(ref:stx.db.body.Refers);
}