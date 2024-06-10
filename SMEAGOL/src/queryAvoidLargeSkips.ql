/**
 * @name Avoid large skips
 * @description Checks if the skips are too large as they impact poorly the performance
 * @kind problem
 * @id queryAvoidLargeSkips
 */

 import javascript
 import utils.findQuery

 from FindQuery findQuery, MethodCallExpr skipUsage
 where 
    skipUsage.getReceiver() = findQuery and 
    findQuery.getMethodName() = "skip"
select findQuery, "This skip performs " + findQuery.getArgument(0).(Literal) + " skips. Please consider using another amount"