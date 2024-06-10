import javascript
import identified_call
import schema_inference_internal
import queryReceiver

class FindQuery extends MethodCallExpr {
    FindQuery() {
        respectAxioms(this) and
        recap(this) and
        ( mongoCollectionSelect(this.getMethodName()) or
        mongoCollectionUpdate(this.getMethodName()) or
        mongoCollectionDelete(this.getMethodName()) or
        mongooseModelDelete(this.getMethodName()) or
        mongooseModelSelect(this.getMethodName()) or
        mongooseModelUpdate(this.getMethodName()) )
    }
    ObjectExpr getFilter() {
        result = any(GeneralObjectExprToArgumentConfig config, DataFlow::Node source, DataFlow::Node sink | 
            this.getArgument(0) = sink.asExpr() and
            config.hasFlow(source, sink) |
            source.asExpr())
    }

    ObjectExpr getProjection() {
        result = any(GeneralObjectExprToArgumentConfig config, DataFlow::Node source, DataFlow::Node sink | 
            this.getArgument(1) = sink.asExpr() and
            config.hasFlow(source, sink) |
            source.asExpr())
    }
    
    VarRef getReturnedDocument() {
        if exists(VariableDeclarator vd|vd.getInit() = this.getParent*())
        then 
            result = any(VariableDeclarator vd | 
                vd.getInit() = this.getParent*() |
                vd.getBindingPattern().getABindingVarRef())
        else
            result = any(Function callback | 
                (callback = this.getLastArgument() or exists(MethodCallExpr chainedCallBack | chainedCallBack.getReceiver*() = this and chainedCallBack = this.getAnArgument())) | 
                callback.getParameter(0).(SimpleParameter).getAnInitialUse())
            
    }

    string getCollectionName() {
        result = this.getReceiver().(QueryReceiver).getCollectionName()
    }


    predicate isCaseSensitive() {
        exists(Property attributeSearch, StringLiteral value| 
            attributeSearch.getParent*() = this.getFilter() and attributeSearch.getInit() = value and
            not(value.getValue().isLowercase()) and not(value.getValue().isUppercase()))
    }
}

class GeneralObjectExprToArgumentConfig extends TaintTracking::Configuration {
    GeneralObjectExprToArgumentConfig() { this = "GeneralObjectExprToArgumentConfig" }
    
    override predicate isSource(DataFlow::Node node) {
        node.asExpr() instanceof ObjectExpr
    }
    
    override predicate isSink(DataFlow::Node node) {
        exists(MethodCallExpr methodCall | 
            methodCall.getAnArgument() = node.asExpr())
    }
}