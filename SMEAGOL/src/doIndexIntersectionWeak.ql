/**
 * @name Index intersection rather than compound index with weak index match
 * @description Index intersection lead to worse performance compared to compound indexes with weak index match
 * @kind alert
 * @id doIndexIntersectionWeak
 */
import javascript
import utils.findQuery
import utils.filterAttributes

from FindQuery findQuery
where 
    count(LeafFilterAttribute attribute | findQuery.getFilter() = attribute.getParent*() | attribute) > 1
    and
    forall(LeafFilterAttribute attribute | findQuery.getFilter() = attribute.getParent*() and not attribute.getFullyQualifiedName().toLowerCase().matches("%id%") | isWeaklyIndexed(attribute.getFullyQualifiedName()))
    and 
    not exists(MongoDBIndexDeclaration indexDecl | forall(LeafFilterAttribute attribute | findQuery.getFilter() = attribute.getParent*() | attribute.getFullyQualifiedName() = indexDecl.getAQualifiedIndexName()))
select findQuery, "This query uses multiple attributes that are separately indexed. Consider using a compound index to increase performance."