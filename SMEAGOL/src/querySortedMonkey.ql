/**
 * @name Sorted Monkeys code smell
 * @description Checks the usage the $push operator with modifiers $slice and $sort bcs when used, replace the whole existing array, which is slow on big ones
 * @kind alert
 * @id querySortedMonkey
 */

import javascript
import utils.updateQuery

from UpdateQuery updateQuery
where exists(
    Property push, Property slice, Property sort, ObjectExpr filter |
    push.getName() = "$push" and slice.getName() = "$slice" and sort.getName() = "$sort" and
    push.getParent+() = filter and
    (filter = slice.getParent+() or filter = sort.getParent+()) and
    updateQuery.getXFilter(1) = filter
    )
select updateQuery, "This query uses a $push with a $sort or/and a $slice modifier, which can be resource-intensive on big array"

// from Property prop
// where prop.getName() = "$push"
// select prop, "$push usage"