/**
 * @name Confusing null & undefined
 * @id queryConfusingNull
 * @kind problem
 * @description Detects whether the usage of undefined value, which is deprecated in BSON.
 */

import javascript
import utils.identified_call
import utils.insertQuery

from InsertQuery insertQuery, InsertedAttribute attr
where insertQuery.getBaseDocument() = attr.getBaseDocument()
and attr.getAttributeType() = "undefined"
select insertQuery, "This query uses an undefined value for attribute " + attr.getFullyQualifiedName() + " . 'undefined' values are deprecated in BSON"