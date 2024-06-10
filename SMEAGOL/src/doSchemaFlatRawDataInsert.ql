/**
 * @name Flat Raw Data
 * @description When a document insert structure lacks embedding. This leads to a collection hardly readable
 * @kind alert
 * @id doSchemaFlatRawDataInsert
 */
import javascript
import utils.insertQuery
import utils.schema_inference_internal

//Abstraction for collection?
from InsertQuery insertQuery
select insertQuery, max(InsertedAttribute attr | attr.getBaseDocument() = insertQuery.getBaseDocument()  | attr.getDepth()).toString() + " : " + count(InsertedAttribute attr | attr.getBaseDocument() = insertQuery.getBaseDocument())