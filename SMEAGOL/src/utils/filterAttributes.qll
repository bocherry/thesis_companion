import schema_inference_internal

class FilterOperator extends ObjectExpr {
    FilterOperator() {
        this.getAProperty().getName().matches("$%")
    }
}

//This should only be used with a pairing findQuery, does not make sense to call it alone
//Removed stricter verifications to gain perf

class LeafFilterAttribute extends GenericAttribute {
    LeafFilterAttribute() {
        this.getInit() instanceof FilterOperator
        or
        this.getInit() instanceof Literal
    }

    override string getFullyQualifiedName() {
        result = this.(GenericAttribute).getFullyQualifiedName()
    }

    override int getDepth() {
        result = this.(GenericAttribute).getDepth()
    }
}