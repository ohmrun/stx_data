package stx.data.store;

class Serialize{
  /**
    I don't trust reuse with the internal state, soz.
  **/
  static public function encode<T>(v:T):String{
    var serializer          = new haxe.Serializer();
        serializer.useCache = true;
        serializer.serialize(v);
    return serializer.toString();
  }
  static public function decode<T>(string:String):T{
    return haxe.Unserializer.run(string);
  }
}