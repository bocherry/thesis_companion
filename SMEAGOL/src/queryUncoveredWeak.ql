/**
 * @name Uncovered queries Weak
 * 
 * @description Indexed queries allow to speed up the process by only scanning the concerned index and not the entire collection
 * @kind alert
 * @id queryUncoveredWeak
 */
import javascript
import utils.queryOperator
import utils.schema_inference_internal

from Operator queryOperator
where not isWeaklyIndexed(queryOperator.getFullyQualifiedName())  and
not queryOperator.getFullyQualifiedName() = "_id"
select queryOperator, "This query is not covered. Consider indexing the attribute/querying an indexed attribute"