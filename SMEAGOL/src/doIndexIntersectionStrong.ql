/**
 * @name Index intersection rather than compound index with strong match
 * @description Index intersection lead to worse performance compared to compound indexes with strong index match
 * @kind alert
 * @id indexIntersection
 */
import javascript
import utils.findQuery
import utils.filterAttributes

from FindQuery findQuery
where 
    count(LeafFilterAttribute attribute | findQuery.getFilter() = attribute.getParent*() and not attribute.getFullyQualifiedName().toLowerCase().matches("%id%") | attribute) > 1
    and
    forall(LeafFilterAttribute attribute | findQuery.getFilter() = attribute.getParent*() and not attribute.getFullyQualifiedName().toLowerCase().matches("%id%") | isStronglyIndexed(attribute.getFullyQualifiedName(), findQuery.getCollectionName()))
    and 
    not exists(MongoDBIndexDeclaration indexDecl | forall(LeafFilterAttribute attribute | findQuery.getFilter() = attribute.getParent*() | attribute.getFullyQualifiedName() = indexDecl.getAQualifiedIndexName() and indexDecl.getCollectionName() = findQuery.getCollectionName()))
select findQuery, "This query uses multiple attributes that are separately indexed. Consider using a compound index to increase performance."