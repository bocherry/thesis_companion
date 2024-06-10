/**
 * @name Querying too much data
 * @description Analogous to transaction script in relational modelling; when querying more data than used in the program. POTENTIALLY REALLY NOISY
 * @kind alert
 * @id doappQueryingTooMuchData
 */

import javascript
import utils.findQuery
import utils.schema_inference_internal

from FindQuery findQuery, VarRef returnedDocument
where
    returnedDocument = findQuery.getReturnedDocument() and
    // inclusion projection
    (exists( ObjectExpr baseProjection, GenericAttribute attribute | 
        findQuery.getProjection() = baseProjection and attribute.getParent*() = baseProjection and 
        attribute.getInit().(NumberLiteral).getIntValue() = 1 and
        not exists(PropAccess attributeAccess | attributeAccess.accesses(returnedDocument.getVariable().getAReference(), attribute.getFullyQualifiedName())) and
        not attribute.getFullyQualifiedName().matches("%_id%"))
    or
    // exclusion projection
    exists(LeafMongoAttribute attribute | 
        not exists(Property prop | findQuery.getProjection().getAProperty() = prop and prop.getInit().(NumberLiteral).getIntValue() != 0) and
        attribute.getCollectionName() = findQuery.getCollectionName() and
        not exists(PropAccess attributeAccess | attributeAccess.accesses(findQuery.getReturnedDocument().getVariable().getAReference(), attribute.getFullyQualifiedName())
        )))
select findQuery, "Every attributes returned by this query are not used in the following code, consider using projection"