/**
 * @name Flat Raw Data
 * @description When a Mongoose Schema structure lacks embedding. This leads to a collection hardly readable
 * @kind alert
 * @id doSchemaFlatRawDataSchema
 */
import javascript
import utils.mongooseSchema
import utils.schema_inference_internal

//Abstraction for collection?
// from InsertQuery insertQuery
// select insertQuery, max(InsertedAttribute attr | attr.getBaseDocument() = insertQuery.getBaseDocument()  | attr.getDepth()).toString() + " : " + count(InsertedAttribute attr | attr.getBaseDocument() = insertQuery.getBaseDocument())

from MongooseSchemaS2 schema
select schema, max(MongooseAttribute attr | attr.getSchema() = schema | attr.getDepth() ) + " : " + count(MongooseAttribute attr | attr.getSchema() = schema)