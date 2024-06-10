/**
 * @name Map-reduce for projection
 * @id aggMapReduceUsage
 * @kind problem
 * @description Detects whether the mapReduce function is used, which is unoptimal compared to the aggregation pipeline
 */

import javascript
import utils.identified_call

from MethodCallExpr call
where 
    call.getMethodName() = "mapReduce" and
    isAMongoCall(call)
select call, "You use mapReduce function, the aggregation pipeline has better performances"