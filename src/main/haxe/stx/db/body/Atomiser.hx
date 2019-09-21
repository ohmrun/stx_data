package stx.db.body;

import fig.head.data.Spine;

import fig.body.Address;
import fig.body.Spine;
import stx.db.head.RNode;


class Atomiser{
  static public function apply(spine:Spine):MDB{
    var mdb = new MDB();
    
    function handler(sp:Spine,?path:LPath):Array<Tuple2<Entity,Tuple2<LPath,RNode>>>{
        if(path == null){
            path = LPath.unit();
        }
        var ent = mdb.create();
        return tuple2(switch(sp){
            case SRecord(rec): 
                switch(path.unbox()){
                    case Root:
                        rec.flatMap(
                            function(l,r){
                                var n_path  = path[l];
                                var n_spine = r();
                                return handler(n_spine,n_path);
                            }.tupled()
                        );
                    default:
                        trace("HERE");
                        var out = handler(sp);
                        var v   = mdb.create();
                    [];
                }
            case SScalar(sc):
                [tuple2(path,Local(sc))];
            case SArray(arr):
                var idx = 0;
                arr.flatMap(
                    function(x){
                        var out =  handler(x(),path[idx]);
                        idx = idx+1;
                        return out;
                    }
                );
            case SEmpty:
                [];
        });
    };
    var out = handler(spine);
    out.each(
        function(x){
            trace(x);
        }
    );
    return mdb;
  }
}