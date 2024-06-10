/**
 * @name Too many collections
 * @description Too many collections in a single project may hinder its maintanability
 * @kind alert
 * @id doSchemaTooManyCollectionsInsert
 */

import javascript
import utils.insertQuery

from InsertQuery insert
select insert, insert.getCollectionName()