/**
 * @name Attributes - schema stats
 * @description Displaying mongoDB attributes stats
 * @kind alert
 * @id statsAttributesSchemaMongoDB
 */
import javascript
import utils.schema_inference_internal

// from LeafInsertedAttribute attribute
from InsertedAttribute attribute
select attribute, attribute.getFullyQualifiedName() + ";;;" + attribute.getCollectionName() + ";;;" + attribute.getAttributeType()