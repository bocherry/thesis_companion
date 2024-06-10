import javascript
import identified_call
import schema_inference_internal
import queryReceiver

abstract class InsertQuery extends MethodCallExpr {
    InsertQuery() {
        respectAxioms(this) and
        recap(this)
    }
    abstract string getCollectionName();
    abstract BaseDocument getBaseDocument();
}

class SaveInsertQuery extends InsertQuery {
    NewExpr documentInit;
    SaveInsertQuery() {
        this.getMethodName() = "save" and
        documentInit = this.getReceiver().(VarRef).getVariable().getADeclarationStatement().getADecl().getInit()
    }

    override BaseDocument getBaseDocument() {
        result = documentInit.getArgument(0)
    }

    override string getCollectionName() {
        result = documentInit.getCalleeName()
    }
}

class GenericInsertQuery extends InsertQuery {
    GenericInsertQuery() {
        mongoCollectionInsert(this.getMethodName())
    }

    override BaseDocument getBaseDocument() {
        if this.getArgument(0) instanceof ObjectExpr
        then 
            result = this.getArgument(0).(BaseDocument)
        else
            result = this.getArgument(0).(VarRef).getVariable().getADeclarationStatement().getADecl().getInit()
    }

    override string getCollectionName() {
        result = this.getReceiver().(QueryReceiver).getCollectionName()
    }
}