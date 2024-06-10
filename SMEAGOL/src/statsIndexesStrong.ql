/**
 * @name Index stats with Schema
 * @description Displaying general index stats
 * @kind alert
 * @id statsIndexesStrong
 */
import javascript
import utils.schema_inference_internal

from MongoIndexDeclaration indexDecl
select indexDecl, indexDecl.getQualifiedIndexName() + ";;;" + indexDecl.getCollectionName()