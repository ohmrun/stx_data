package stx.data;

using stx.data.Test;

typedef ReadableStoreApi<K,V>       = stx.data.store.ReadableStoreApi<K,V>;
typedef SettableStoreApi<K,V>       = stx.data.store.SettableStoreApi<K,V>;
typedef ReferenceStoreApi<K,V>      = stx.data.store.ReferenceStoreApi<K,V>;
typedef Articulation<K>             = stx.data.store.Articulation<K>;
typedef StoreValSum<K,V>            = stx.data.store.StoreVal.StoreValSum<K,V>;
typedef StoreValLift                = stx.data.store.StoreVal.StoreValLift;
typedef StoreVal<K,V>               = stx.data.store.StoreVal<K,V>;