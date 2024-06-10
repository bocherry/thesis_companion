/**
 * @name Case-insensitive queries without matching weak indexes
 * @description Index are by default case sensitive. If the query uses query insensitive data, then the index must be adapted accordingly
 * @kind alert
 * @id queryCaseInsensitiveWoIndexWeak
 */
import javascript
import utils.schema_inference_internal
import utils.findQuery
import utils.queryOperator

from Operator queryOperator
where 
    queryOperator.isCaseSensitive() and 
    isWeaklyIndexCaseSensitive(queryOperator.getFullyQualifiedName())
select queryOperator, "This query is case sensitive while the defined index is not. Consider setting the index colation right"