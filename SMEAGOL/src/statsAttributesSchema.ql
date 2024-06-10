/**
 * @name Attributes - schema stats
 * @description Displaying general attributes stats
 * @kind alert
 * @id statsAttributesSchema
 */
import javascript
import utils.schema_inference_internal

from MongoAttribute attribute
select attribute, attribute.getFullyQualifiedName() + ";;;" + attribute.getAttributeType() + ";;;" + attribute.getCollectionName()