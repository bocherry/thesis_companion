/**
 * @name Using a Document only for id field
 * @description Using a document only as its id fields is unefficient and may show a misunderstanding of the index concept
 * @kind alert
 * @id doSchemaUsingDocumentIdInsert
 */
import javascript
import utils.schema_inference_internal
import utils.insertQuery

from InsertQuery insertQuery
where 
    count(InsertedAttribute attr | attr.getBaseDocument() = insertQuery.getBaseDocument() | attr) = 1
    and
    exists(InsertedAttribute attr | attr.getBaseDocument() = insertQuery.getBaseDocument() and attr.getFullyQualifiedName().toLowerCase().matches("%id%"))
select insertQuery, "This insert query only has one attribute as id"