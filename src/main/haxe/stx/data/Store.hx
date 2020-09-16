package stx.data;

using stx.data.Test;

typedef Serialize                   = stx.data.store.Serialize;
typedef ReadableStoreApi<K,V>       = stx.data.store.ReadableStoreApi<K,V>;
typedef SettableStoreApi<K,V>       = stx.data.store.SettableStoreApi<K,V>;
typedef StoreApi<K,V>               = stx.data.store.StoreApi<K,V>;

typedef BlockChain<K,V>             = stx.data.store.BlockChain<K,V>;
typedef FileSystemBlockChain<K,V>   = stx.data.store.block_chain.term.FileSystemBlockChain<K,V>;
typedef Articulation<K>             = stx.data.store.block_chain.Articulation<K>;
typedef BlockChainDeps<K,V>         = stx.data.store.block_chain.BlockChainDeps<K,V>;