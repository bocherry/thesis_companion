/**
 * @name Index stats
 * @description Displaying general index stats
 * @kind alert
 * @id statsIndexesWeak
 */
import javascript
import utils.schema_inference_internal

from MongoIndexDeclaration indexDecl
select indexDecl, indexDecl.getQualifiedIndexName()