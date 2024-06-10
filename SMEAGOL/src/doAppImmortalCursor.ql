/**
 * @name Immortal Cursor
 * @description When a cursor is not properly closed after a query
 * @kind alert
 * @id doAppImmortalCursor
 */

import javascript
import utils.query

class QueryCloseConfig extends TaintTracking::Configuration {
    QueryCloseConfig() { this = "QueryCloseConfig" }
    
    override predicate isSource(DataFlow::Node node) {
        node.asExpr() instanceof Query
    }
    
    override predicate isSink(DataFlow::Node node) {
        exists(MethodCallExpr close | 
            close.getMethodName() = "close" and node.asExpr() = close.getReceiver())
    }
}

from Query query 
where not exists(QueryCloseConfig config, MethodCallExpr closeCall | 
    config.hasFlow(query.flow(), closeCall.getReceiver().flow()))
select query, "The cursor opened for this query is not closed"