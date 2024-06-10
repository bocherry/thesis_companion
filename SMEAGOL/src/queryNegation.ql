/**
 * @name Negation in queries
 * @description Using negation in queries may end up in a complete collection scan, which is slow and unefficient
 * @kind alert
 * @id queryNegation
 */

import javascript
import utils.findQuery
import utils.updateQuery

from Property operator
where
    exists( FindQuery findQuery, UpdateQuery updateQuery, ObjectExpr filter | 
        (findQuery.getFilter() = filter or updateQuery.getAFilter() = filter) and
        operator.getParent*() = filter)
    and
    operator.getName() in ["$not", "$ne"]
select operator, "This query uses a negation operators, which performs a complete collection scan, ignoring indexes"