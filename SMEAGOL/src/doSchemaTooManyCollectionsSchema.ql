/**
 * @name Too many collections
 * @description Too many collections in a single project may hinder its maintanability
 * @kind alert
 * @id doSchemaTooManyCollectionsSchema
 */

import javascript
import utils.mongooseSchema

from MongooseSchemaS2 schema
select schema, schema.getName()