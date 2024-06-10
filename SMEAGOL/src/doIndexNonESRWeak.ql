/**
 * @name Non-ESR compound indexes (Equality, Sort, range) with weak Index matching
 * @description Not respecting the ESR rule for compound index. A compound index order should reflect the usage in a query (first the attribute on which the equality is performed, then the one for sorting and then the one for the range) for better performances
 * @kind alert
 * @id doIndexNonESRWeak
 */
import javascript
import utils.schema_inference_internal
import utils.findQuery
import utils.filterAttributes


from MongoMethodIndexDeclaration indexDecl
where 
    count(indexDecl.getAQualifiedIndexName()) > 2
    and
    exists(FindQuery findQuery, MethodCallExpr sortCall, LeafFilterAttribute filterAttribute, GenericLeafAttribute sortAttribute | 
        filterAttribute.getParent*() = findQuery.getFilter() and sortCall.getArgument(0) = sortAttribute.getParent*() and 
        sortCall.getReceiver() = findQuery.getParent*() and
        filterAttribute.getFullyQualifiedName() = indexDecl.getAQualifiedIndexName() and sortAttribute.getFullyQualifiedName() = indexDecl.getAQualifiedIndexName() and
        
        exists( Property indexParentFilterAttribute, int numIndexParentFilterAttribute, Property indexParentSortAttribute, int numindexParentSortAttribute| 
            indexDecl.getArgument(0).(ObjectExpr).getProperty(numIndexParentFilterAttribute) =  indexParentFilterAttribute and 
            indexDecl.getArgument(0).(ObjectExpr).getProperty(numindexParentSortAttribute) =  indexParentSortAttribute and
            numIndexParentFilterAttribute != numindexParentSortAttribute and
            numIndexParentFilterAttribute > numindexParentSortAttribute and
            exists(Property indexChildFilterAttribute, Property indexChildSortAttribute | indexChildFilterAttribute.getInit() instanceof Literal and indexChildSortAttribute.getInit() instanceof Literal and 
            indexParentFilterAttribute = indexChildFilterAttribute.getParent*() and indexParentSortAttribute = indexChildSortAttribute.getParent*())
            ))
select indexDecl, "This compound index does not respect the ESR rule. Consider altering the order to comply"