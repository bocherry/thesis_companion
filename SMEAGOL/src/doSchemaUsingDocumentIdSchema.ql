/**
 * @name Using a Document only for id field
 * @description Using a document only as its id fields is unefficient and may show a misunderstanding of the index concept
 * @kind alert
 * @id doSchemaUsingDocumentIdSchema
 */
import javascript
import utils.schema_inference_internal
import utils.mongooseSchema

from MongooseSchemaS2 schema
where 
    count(MongooseAttribute attr | attr.getSchema() = schema | attr) = 1
    and
    exists(MongooseAttribute attr | attr.getSchema() = schema and attr.getFullyQualifiedName().toLowerCase().matches("%id%"))
select schema, "This Schema only has one attribute as id"