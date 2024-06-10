import javascript

class MongooseSchemaS2 extends InvokeExpr {
    MongooseSchemaS2() {
        this.getCalleeName() = "Schema" and
        not exists(Property prop | getDescendant(prop) = this)
    }
    string getName() {
        result = any(MethodCallExpr modelCall, MongooseSchemaNameTracking config |
            config.hasFlow(this.flow(), modelCall.getArgument(1).flow()) |
            modelCall.getArgument(0).(StringLiteral).getValue()
            )
    }
    string getTypeKeyName() {
        result = this.getArgument(1).(ObjectExpr).getPropertyByName("typeKey").getInit().(StringLiteral).getValue()
    }

    int getCollationStrength() {
        if exists(Property collation | collation.getParent*() = this.getArgument(1) and collation.getName() = "collation" and  exists(collation.getInit().(ObjectExpr).getPropertyByName("strength")))
        then result = any(Property collation | collation.getParent*() = this.getArgument(1) and collation.getName() = "collation" | collation.getInit().(ObjectExpr).getPropertyByName("strength").getInit().(NumberLiteral).getIntValue() )
        else result = 3
    }

    predicate isCaseSensitive() {
        this.getCollationStrength() > 2
    }
}
ASTNode getDescendant(ASTNode node) {
    result = node.getAChild() or
    result = getDescendant(node.getAChild())
}

class MongooseSchemaNameTracking extends TaintTracking::Configuration {
    MongooseSchemaNameTracking() {this="MongooseSchemaNameTracking"}

    override predicate isSource(DataFlow::Node node) {
        exists(MongooseSchemaS2 mongooseSchema | 
            mongooseSchema.flow() = node)
    }

    override predicate isSink(DataFlow::Node node) {
        exists(MethodCallExpr model | 
            model = DataFlow::moduleMember("mongoose", "model").getACall().asExpr().(MethodCallExpr)
            and model.getArgument(1) = node.asExpr())
    }
}