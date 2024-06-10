import findQuery
import updateQuery

class Operator extends GenericAttribute {
    GenericAttribute parentAttribute;
    MethodCallExpr parentQuery;
    Operator() {
        exists( FindQuery findQuery, UpdateQuery updateQuery | (findQuery.getFilter() = this.getParent+() and parentQuery = findQuery) or (updateQuery.getAFilter() = this.getParent+() and parentQuery = updateQuery ) )and
        this.getName().matches("$%") and
        parentAttribute.getInit() = this.getObjectExpr()
    }

    override string getFullyQualifiedName() {
        result = parentAttribute.getFullyQualifiedName() + "." + this.getName()
    }

    string getCollectionName() {
        if parentQuery instanceof FindQuery
        then result = parentQuery.(FindQuery).getCollectionName()
        else result = parentQuery.(UpdateQuery).getCollectionName()
    }

    predicate isCaseSensitive() {
        if parentQuery instanceof FindQuery
        then parentQuery.(FindQuery).isCaseSensitive()
        else parentQuery.(UpdateQuery).isCaseSensitive()
    }
    override int getDepth() {
        result = 1 + parentAttribute.getDepth()
    }
    MethodCallExpr getParentQuery() {
        result = parentQuery
    }
    GenericAttribute getParentAttribute() {
        result = parentAttribute
    }
}