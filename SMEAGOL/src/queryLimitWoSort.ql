/**
 * @name Using $limit withtout $sort
 * @description Checks if a query that uses $limit also uses $sort. If it does not, its results are non-deterministic
 * @kind alert
 * @id queryLimitWoSort
 */

import javascript
import utils.findQuery
import utils.aggregateCall

// from FindQuery findQuery
// where exists(
//     MethodCallExpr limitCall, MethodCallExpr sortCall | 
//     limitCall.getMethodName() = "limit" and sortCall.getMethodName() = "sort" and

// )
from Expr query
where 
    exists( FindQuery findQuery | 
        findQuery = query and 
        exists(MethodCallExpr limitCall | 
            limitCall.calls(findQuery.getParent*(), "limit"))  and 
        not exists(MethodCallExpr sortCall | 
            sortCall.calls(findQuery.getParent*(), "sort") ))
    or 
    
    exists( AggregateCall aggregate | 
        aggregate = query and 
        exists( Property limitProperty | 
            limitProperty.getName() = "$limit" and limitProperty.getParent*() = aggregate.getAnArgument())
        and
        not exists( Property sortProperty | 
            sortProperty.getName() = "$sort" and sortProperty.getParent*() = aggregate.getAnArgument())
    )
   
select query, "This query uses a limit without a sort, which can result in non-deterministic result"