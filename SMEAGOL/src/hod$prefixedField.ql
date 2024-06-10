/**
 * @name Using $ prefixed Field
 * @description MongoDB does not allow $ prefixed fields, this wills raise an error
 * @kind alert
 * @id hod$prefixedField
 */
import javascript
import utils.schema_inference_internal

from MongoAttribute attribute
where attribute.getFullyQualifiedName().matches("$%")
select attribute, "This attribute is prefixed with a $; this will raise an error"