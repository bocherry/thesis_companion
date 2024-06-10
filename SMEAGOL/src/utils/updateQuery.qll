import identified_call
import queryReceiver

class SecondFilterTrackingConfig extends TaintTracking::Configuration {
    SecondFilterTrackingConfig() { this = "SecondFilterTrackingConfig" }
    
    override predicate isSource(DataFlow::Node node) {
        node.asExpr() instanceof ObjectExpr
    }
    
    override predicate isSink(DataFlow::Node node) {
        exists(MethodCallExpr updateCall | 
            node.asExpr() = updateCall.getAnArgument())
    }
}

class UpdateQuery extends MethodCallExpr {
    UpdateQuery() {
        mongoCollectionUpdate(this.getMethodName()) and
        mongooseModelUpdate(this.getMethodName()) and
        isAMongoCall(this)
    }

    ObjectExpr getXFilter(int filterNumber) {
        result = any(SecondFilterTrackingConfig config, DataFlow::Node source , DataFlow::Node sink | 
            config.hasFlow(source, sink) and
            this.getArgument(filterNumber) = sink.asExpr() | 
            source.asExpr() )
    }

    ObjectExpr getAFilter() {
        result = any(SecondFilterTrackingConfig config, DataFlow::Node source , DataFlow::Node sink | 
            config.hasFlow(source, sink) and
            this.getAnArgument() = sink.asExpr() | 
            source.asExpr() )
    }

    string getCollectionName() {
        result = this.getReceiver().(QueryReceiver).getCollectionName()
    }

    predicate isMultiUpdate() {
        this.getMethodName() = "udpateMany" or
        exists(Property multi | multi.getName() = "multi" and multi.getInit().(BooleanLiteral).getValue() = "true" and multi.getParent+() = this.getXFilter(2))
    }

    predicate isCaseSensitive() {
        exists(Property attributeSearch, StringLiteral value| 
            attributeSearch.getParent*() = this.getXFilter(0) and attributeSearch.getInit() = value and
            not(value.getValue().isLowercase()) and not(value.getValue().isUppercase()))
    }
}