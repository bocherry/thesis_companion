import javascript

class QueryReceiverMongooseModelConfig extends TaintTracking::Configuration {
    QueryReceiverMongooseModelConfig() {
        this = "QueryReceiverMongooseModelConfig"
    }

    override predicate isSource(DataFlow::Node node) {
        node = DataFlow::moduleMember("mongoose", "model").getACall()
    }
    override predicate isSink(DataFlow::Node node) {
        exists(MethodCallExpr mce | node.asExpr() = mce.getReceiver())
    }
}

abstract class QueryReceiver extends Expr {
    abstract string getCollectionName();
}

class QueryReceiverMongooseModel extends QueryReceiver {
    DataFlow::CallNode mongooseModelCall;
    QueryReceiverMongooseModel() {
        mongooseModelCall = DataFlow::moduleMember("mongoose", "model").getACall() and
        exists(QueryReceiverMongooseModelConfig config | config.hasFlow(mongooseModelCall, this.flow()))
    }

    override string getCollectionName() {
        result = mongooseModelCall.asExpr().(MethodCallExpr).getArgument(0).(StringLiteral).getValue()
    }
}

class QueryReceiverDBCollectionCall extends MethodCallExpr, QueryReceiver {
    QueryReceiverDBCollectionCall() {
        this.getMethodName() = "collection"
    }

    override string getCollectionName() {
        result = this.getArgument(0).(StringLiteral).getValue()
    }
}

class QueryReceiverDBCollectionDotExpr extends DotExpr, QueryReceiver {
    override string getCollectionName() {
        result = this.getPropertyName()
    }
}