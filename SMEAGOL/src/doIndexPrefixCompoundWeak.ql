/**
 * @name Prefix index of compound indexes with weak index match
 * @description When an index is declared individually and as a prefix of a compound index
 * @kind alert
 * @id doIndexPrefixCompoundWeak
 */
import javascript
import utils.schema_inference_internal

from MongoIndexDeclaration indexDecl
where 
    count(indexDecl.getAQualifiedIndexName()) = 1
    and
    exists( MongoIndexDeclaration otherIndexDecl | otherIndexDecl != indexDecl and otherIndexDecl.getAQualifiedIndexName() = indexDecl.getAQualifiedIndexName() and count(otherIndexDecl.getAQualifiedIndexName()) > 1)
select indexDecl, "This index is used in another compound index declaration. Consider removing this individual index"