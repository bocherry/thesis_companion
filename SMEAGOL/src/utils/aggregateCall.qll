import identified_call
import javascript
import queryReceiver

int getVarRefStageNum(VarRef varRef) {
    result = varRef.getVariable().getADeclarationStatement().getDecl(0).getInit().(ArrayExpr).getSize() or
    result = varRef.getVariable().getADeclarationStatement().getDecl(0).getInit().(ObjectExpr).getNumProperty()
}

class AggregateCall extends MethodCallExpr {
    AggregateCall() {
        this.getMethodName() = "aggregate" and
        isAMongoCall(this)
    }

    int getAggregationStagesNumber() {
        if this.getArgument(0) instanceof VarRef
        then result = getVarRefStageNum(this.getArgument(0))
        else 
            if this.getArgument(0) instanceof ArrayExpr
            then result = this.getArgument(0).(ArrayExpr).getSize()
            else
                if this.getArgument(0) instanceof ObjectExpr and this.getArgument(0).(ObjectExpr).getNumProperty() > 1
                then result = this.getArgument(0).(ObjectExpr).getNumProperty()
                else 
                    result = count(ObjectExpr stage | stage = this.getAnArgument() | stage)
        }
    
    ObjectExpr getAStageByName(string stageName) {
        if this.getArgument(0) instanceof ArrayExpr
        then
            result = this.getArgument(0).(ArrayExpr).getAnElement().(ObjectExpr).getPropertyByName(stageName).getInit()
        else
            result = this.getAnArgument().(ObjectExpr).getPropertyByName(stageName).getInit()
    }

    string getBaseCollectionName() {
        result = this.getReceiver().(QueryReceiver).getCollectionName()
    }
}