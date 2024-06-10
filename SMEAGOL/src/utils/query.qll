import javascript
import findQuery
import insertQuery
import updateQuery

class Query extends MethodCallExpr {
    Query() {
        this instanceof FindQuery 
        or
        this instanceof InsertQuery
        or 
        this instanceof UpdateQuery
    }
}