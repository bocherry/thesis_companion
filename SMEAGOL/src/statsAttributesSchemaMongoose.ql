/**
 * @name Attributes - schema stats
 * @description Displaying mongoose attributes stats
 * @kind alert
 * @id statsAttributesSchemaMongoose
 */
import javascript
import utils.schema_inference_internal

from MongooseAttribute attribute
select attribute, attribute.getFullyQualifiedName() + ";;;" + attribute.getAttributeType() + ";;;" + attribute.getCollectionName()