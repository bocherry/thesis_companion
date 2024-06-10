/**
 * @name No $elemMatch to match an entire array
 * @description Checks if $elemMatch is used to match an entire array. If not, harms performance.
 * @kind problem
 * @id queryNoElemMatch
 */
import javascript
import utils.findQuery
import utils.schema_inference_internal
import utils.queryOperator

from FindQuery findQuery, Operator operator, MongoAttribute attribute
where 

    findQuery.getFilter() = operator.getParent+() 
    and operator.getName() != "$elemMatch" 
    and attribute.getFullyQualifiedName() = operator.getFullyQualifiedName() 
    and attribute.getCollectionName() = findQuery.getCollectionName() 
    and attribute.getAttributeType().toLowerCase() = "array"

select findQuery, "This query is made on " + attribute.getFullyQualifiedName() +" array attribute, however the $elemMatch operator is not used."