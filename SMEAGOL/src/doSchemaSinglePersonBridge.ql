/**
 * @name The single person bridge
 * @description Simulating a SQL sequence using a dedicated document and findAndModify/findAndUpdate method. Documents are write lock, as a consequence with many writes to a single document are slow.
 * @kind alert
 * @id doSchemaSinglePersonBridge
 */

import javascript
import utils.updateQuery

from UpdateQuery updateQuery
where 
    exists(Property prop | 
        prop.getName() = "$inc" and prop.getParent*() = updateQuery.getAFilter())
select updateQuery, "This query performs an incrementation. This could be a SQL sequence in MongoDB, which is unnecessary."