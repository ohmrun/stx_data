package stx.data.store;

typedef HasHash<T> = {
  function hash(v:T):String;
}