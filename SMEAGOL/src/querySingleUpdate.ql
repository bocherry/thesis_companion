/**
 * @name Single update/insert for batches
 * @description When not using the right options when updating a whole collection i.e. using smth else than the _id field
 * @kind alert
 * @id querySingleUpdate
 */

 import javascript
 import utils.updateQuery

from UpdateQuery updateQuery
where 
    not updateQuery.isMultiUpdate() and
    updateQuery.getMethodName() = "update" and
    not exists(Property idAccess | 
            idAccess.getParent() = updateQuery.getXFilter(0) and
            idAccess.getName().matches("%id") and
            ( not idAccess.getInit() instanceof ObjectExpr 
              or exists(idAccess.getInit().(ObjectExpr).getPropertyByName("$eq") ) ))
select updateQuery, "This query is performing a single update while it's projection filter is not a strict equality"