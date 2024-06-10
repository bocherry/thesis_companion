/**
 * @name Case-insensitive queries without strong matching indexes
 * @description Index are by default case sensitive. If the query uses query insensitive data, then the index must be adapted accordingly
 * @kind alert
 * @id queryCaseInsensitiveWoIndexStrong
 */
import javascript
import utils.schema_inference_internal
import utils.findQuery
import utils.queryOperator

from Operator queryOperator
where 
    queryOperator.isCaseSensitive() and 
    isStronglyIndexed(queryOperator.getFullyQualifiedName(), queryOperator.getCollectionName()) and
    not isStronglyIndexedCaseSensitive(queryOperator.getFullyQualifiedName(), queryOperator.getCollectionName())
select queryOperator, "This query is case sensitive while the defined index is not. Consider setting the index colation right"