/**
 * @name Repeated immutable data
 * @description When documents are inserted with a recurring immutable data in it, (e.g. a complete user configuration). It could indicate the need to factorise this data in another collection
 * @kind alert
 * @id doSchemaRepeatedImmutable
 */

 import javascript
 import utils.insertQuery

 from ObjectExpr insertedData, ObjectExpr otherInsertedData
 where 
     exists(InsertQuery insertQuery1, InsertQuery insertQuery2 | insertQuery1.getBaseDocument() = insertedData.getParent*() and insertQuery2.getBaseDocument() = otherInsertedData.getParent*()) and
     insertedData != otherInsertedData and
     forall( Property prop | insertedData = prop.getParent*() | exists(otherInsertedData.getPropertyByName(prop.getName())) and otherInsertedData.getPropertyByName(prop.getName()).getInit().(Literal).getValue() = prop.getInit().(Literal).getValue()) and
     forall( Property prop | otherInsertedData = prop.getParent*() | exists(insertedData.getPropertyByName(prop.getName())) and insertedData.getPropertyByName(prop.getName()).getInit().(Literal).getValue() = prop.getInit().(Literal).getValue())
 select insertedData, "This data is already inserted somewhere else in the program (" + otherInsertedData.getLocation().toString() + "). Please consider factoring it in another collection."