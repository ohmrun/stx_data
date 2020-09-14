package stx.data.store;

typedef With<T,X> = {
  public var data(default,null):T;
  public var with(default,null):X;
}