/**
 * @name Avoid $where operator
 * @id queryAvoidWhere
 * @kind problem
 * @description Detects whether the usage of $where operator, which allows arbitrary JS code execution and prevent from using indexes.
 */

import javascript
import utils.findQuery

from FindQuery findQuery
where 
    exists(Property operator | operator.getName() = "$where" and operator.getParent+() = findQuery.getFilter())
select findQuery, "This query uses a where operator, which allows arbitrary JS code execution and prevent from using indexes. Please consider using an alternative"