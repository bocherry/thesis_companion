/**
 * @name Multiple Schemas in a file
 * @description Defining multiple Mongoose Schemas in a file makes it harder to read through the project. Having 1 schema per file ease the access through your code for a newcomer
 * @kind alert
 * @id doSchemaTooMuchSchema
 */

 import javascript
 import utils.mongooseSchema

from File file
where 
    count(MongooseSchemaS2 schema | schema.getFile() = file) > 1
select file, "This file has more than one schema. Please use 1 schema per file as it makes it harder to go through your project" 