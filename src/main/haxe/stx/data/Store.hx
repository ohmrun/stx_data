package stx.data;

using stx.data.Test;

typedef ReadableStoreApi<K,V>       = stx.data.store.ReadableStoreApi<K,V>;
typedef SettableStoreApi<K,V>       = stx.data.store.SettableStoreApi<K,V>;
typedef ReferenceStoreApi<K,V>      = stx.data.store.ReferenceStoreApi<K,V>;
typedef Articulation<K>             = stx.data.store.Articulation<K>;
typedef BlockChain<K,V>             = stx.data.store.BlockChain<K,V>;
typedef BlockChainDeps<K,V>         = stx.data.store.block_chain.BlockChainDeps<K,V>;