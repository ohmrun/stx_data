package stx.fail;

enum DataFailure{
  E_Data_KeyNotFound(k:Any);
  E_Data_CannotWrite;
  E_Db_Unimplemented;
}