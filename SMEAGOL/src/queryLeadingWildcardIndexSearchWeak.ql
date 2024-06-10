/**
 * @name Leading wildcard searches on weakly indexed columns
 * @description Leading wildcards searches on indexed columns result in an entire collection scan which is slow
 * @kind alert
 * @id queryLeadingWildcardIndexSearchWeak
 */

import javascript
import utils.queryOperator
import utils.schema_inference_internal

from Operator operator
where 
    operator.getInit().(StringLiteral).getValue().matches("$**%")
    and
    isWeaklyIndexed(operator.getFullyQualifiedName())
select operator, "This query uses a leading wildcard on an indexed column, which results in an entire collection scan"