import javascript
import identified_call
import mongooseSchema
import insertQuery

// predicate testFile(File f) {
//     //Jasmine test files
//     f.getAbsolutePath().matches("%.spec.%") or 
//     // f.getAbsolutePath().matches("%test%") or
//     f.getAbsolutePath().matches("%.jsx")
// }

abstract class MongoInsertOperation extends MethodCallExpr{
    abstract InsertedDocument getDocument();
    abstract string getCollectionName();

}

class BulkOperationInsert extends MongoInsertOperation {
    MethodCallExpr initialisationCall;

    BulkOperationInsert() {
        this.getMethodName() = "insert" and
        initialisationCall.getMethodName() in  ["initializeUnorderedBulkOp", "initializeOrderedBulkOp"] and
        initialisationCall.flow().getASuccessor+().asExpr() = this.getReceiver()
    }

    override InsertedDocument getDocument() {
        result = this.getArgument(0)
    }
    override string getCollectionName() {
        result = initialisationCall.getReceiver().(CollectionReceiver).getCollectionName()
    }
}



class MongoDB_DBCollectionInsert extends MongoInsertOperation{
    MongoDB_DBCollectionInsert() {
        this.getMethodName() in ["insert", "insertMany", "insertOne"] and
        mongoDBCall(this) and
        not this instanceof BulkOperationInsert
    }
    override InsertedDocument getDocument() {
        result = this.getArgument(0)
    }

    override string getCollectionName() {
        result = this.getReceiver().(CollectionReceiver).getCollectionName()
    }
}

abstract class CollectionReceiver extends Expr{
    abstract string getCollectionName();
}

class DBCollectionMethodCallExpr extends CollectionReceiver, MethodCallExpr {
    override string getCollectionName() {
        result = this.getArgument(0).getStringValue()
    }
}

class DBCollectionDotExpr extends CollectionReceiver, DotExpr {
    override string getCollectionName() {
        result = this.getPropertyName()
    }
}

class CollectionVarExpr extends CollectionReceiver, VarRef {
    override string getCollectionName() {
        result = this.getName()
    }
}

class MongooseSaveInsert extends MongoInsertOperation {
    NewExpr docCreation;
    DataFlow::ModuleImportNode modelImport;
    MongooseSaveInsert() {
        this.getMethodName() = "save" and
        docCreation.flow().(DataFlow::NewNode).getASuccessor+().asExpr() = this.getReceiver() and
        modelImport.getASuccessor+().asExpr() = docCreation.getCallee() and
        exists( MongooseSchemaS2 schema | modelImport.asExpr().(Import).resolveImportedPath().getFile() = schema.getFile())
    }

    override InsertedDocument getDocument() {
        result = docCreation.getArgument(0)
    }

    override string getCollectionName() {
        result = docCreation.getCalleeName()
    }
}

class MongooseCreateInsertMany extends MongoInsertOperation {
    DataFlow::ModuleImportNode modelImport;
    MongooseCreateInsertMany() {
        this.getMethodName() in ["insertMany", "create"] and
        modelImport.getASuccessor+().asExpr() = this.getReceiver() and 
        exists( MongooseSchemaS2 schema | modelImport.asExpr().(Import).resolveImportedPath().getFile() = schema.getFile())
    }

    override InsertedDocument getDocument() {
        result = this.getArgument(0)
    }
    override string getCollectionName() {
        result = this.getReceiver().(VarRef).getName()
    }
}

abstract class InsertedDocument extends Expr{
    abstract string getLocations();
}

class SingleDocument extends InsertedDocument, ObjectExpr {
    override string getLocations() {
        result = concat(getDoc(this), ",,,")
    }
}

class MultipleDocuments extends InsertedDocument, ArrayExpr {
    override string getLocations() {
        result = concat( SingleDocument doc | this.getAnElement() = doc | doc.getLocations(), " | " )
    }
}

class VarDocument extends InsertedDocument, VarRef {
    VariableDeclarator docDecl;
    VarDocument() {
        docDecl = this.getVariable().getADeclarationStatement().getADecl() and
        docDecl.getBindingPattern().getName() = this.getName()
    }
    override string getLocations() {
        result = docDecl.getInit().(SingleDocument).getLocations() + ",,," + concat(DataFlow::PropWrite propWrite, string property | propWrite.accesses(docDecl.getBindingPattern().getVariable().getAnAccess().flow(), property) | concat(property + " :: " + getDoc(propWrite.getRhs().asExpr()), ",,,") , ",,,")
    }
}

string determineType(DataFlow::PropWrite propw) {
    result = propw.getRhs().analyze().getTheType().toString() or
    result = propw.getBase().asExpr().(VarRef).getVariable().getADefinition().getSource().(ObjectExpr).getPropertyByName(propw.getPropertyName()).getInit().analyze().getTheType().toString() or
    result = propw.getRhs().asExpr().getType().toString() or
    result = propw.getRhs().asExpr().(MethodCallExpr).getDocumentation().toString() or
    result = "any"
}

string getTypeInf(Expr expr) {
    if exists(expr.analyze().getTheType())
    then 
        result = expr.analyze().getTheType().toString() 
    else
        // result = expr.(PropAccess).getBase().(VarRef).getVariable().getADefinition().getSource().(ObjectExpr).getPropertyByName(expr.(PropAccess).getPropertyName()).getInit().analyze().getTheType().toString() or
        result = "any"
}


string getDoc(ASTNode expr) {
    result = expr.(Literal).getValue() + "*type*" + getTypeInf(expr) or
    result = expr.(VarRef).getName() + "*type*" + getTypeInf(expr) or
    result = expr.(InvokeExpr).getCalleeName() + "()" + "*type*" + getTypeInf(expr) or
    result = expr.(DotExpr).toString() + "*type*" + getTypeInf(expr) or
    result = expr.(IndexExpr).toString() + "*type*" + getTypeInf(expr) or
    result = getDoc(expr.(ConditionalExpr).getAlternate()) or
    result = getDoc(expr.(TemplateLiteral).getAnElement()) or
    result = getDoc(expr.(ObjectExpr).getAProperty()) or 
    result = expr.(Property).getName() + " :: " + getDoc(expr.(Property).getInit()) or
    result = " -array- " + getDoc(expr.(ArrayExpr).getAnElement())    
}


// from MongoInsertOperation insert
// select insert, insert.getLocation().getStartLine() + ":" + insert.getLocation().getStartColumn() + "," + insert.getLocation().getEndLine() + ":" + insert.getLocation().getEndColumn() + ";;" + insert.getCollectionName() + ";;" + insert.getDocument().getLocations()

// This construction is ugly but I am yet to find a better way

abstract class MongoAttribute extends ASTNode {
    abstract string getFullyQualifiedName();
    abstract string getCollectionName();
    abstract string getAttributeType();
    abstract int getDepth();
}


abstract class MongooseAttribute extends MongoAttribute, Property {
    abstract MongooseSchemaS2 getSchema();
    override abstract string getFullyQualifiedName();
    override string getAttributeType() {    
        if this.getInit() instanceof MongooseTypeObject
        then result = this.getInit().(MongooseTypeObject).getAttributeType()
        else 
            if this.getInit().(ArrayExpr).getAnElement() instanceof MongooseTypeObject
            then result = "[" + this.getInit().(ArrayExpr).getAnElement().(MongooseTypeObject).getAttributeType() + "]"
            else 
                if this.getInit() instanceof ArrayExpr
                then result = "Array Embeddation"
                else
                    if this.getInit() instanceof ObjectExpr
                    then result = "Embbedation"
                    else
                        result = this.getInit().(LeafDataType).getInitValue()
            

    }

    override string getCollectionName() {
        result = this.getSchema().getName()
    }
}

class MongooseTypeObject extends ObjectExpr {
    Property typeProperty;
    MongooseAttribute parentAttr;
    MongooseTypeObject() {
        this.getAProperty() = typeProperty and
        (parentAttr.getInit() = this or parentAttr.getInit().(ArrayExpr).getAnElement() = this) and
        if exists(parentAttr.getSchema().getTypeKeyName())
        then this.getPropertyByName(parentAttr.getSchema().getTypeKeyName()) = typeProperty 
        else typeProperty.getName() in ["type", "$type"]
        
    }

    string getAttributeType() {
        result = typeProperty.getInit().(VarRef).getName() or
        result = typeProperty.getInit().(DotExpr).getQualifiedName()
    }
    predicate isIndex() {
        exists(this.getPropertyByName("index"))
    }
}

class Mongoose1stOrderAttribute extends MongooseAttribute {
    MongooseSchemaS2 parentSchema;

    Mongoose1stOrderAttribute() {
        this.getObjectExpr() = parentSchema.getArgument(0)
    }

    override MongooseSchemaS2 getSchema() {
        result = parentSchema
    }

    override string getFullyQualifiedName() {
        result = this.getName()
    }

    override int getDepth() {
        result = 1
    }
}


class MongooseArrayAttribute extends MongooseAttribute {
    MongooseAttribute parent;
    MongooseSchemaS2 schema;

    MongooseArrayAttribute() {
        this.getObjectExpr() = parent.getInit().(ArrayExpr).getAnElement()
        // Non monotonic codeql recursion made me do this
     }
    
    override MongooseSchemaS2 getSchema() {
        result = parent.getSchema()
    }
    override string getFullyQualifiedName() {
        result = parent.getFullyQualifiedName() + ".[" + this.getName() + "]"
    }

    override int getDepth() {
        result = 1 + parent.getDepth()
    }


}

class MongooseIntermediateAttribute extends MongooseAttribute {
    MongooseAttribute parent;

    MongooseIntermediateAttribute() {
        this.getObjectExpr() = parent.getInit() and
        not exists(Property prop | prop.getName() = "$type" and prop = this.getObjectExpr().getAProperty())
    }

    override MongooseSchemaS2 getSchema() {
        result = parent.getSchema()
    }
    override string getFullyQualifiedName() {
        result = parent.getFullyQualifiedName() + "." + this.getName()
    }
    override int getDepth() {
        result = 1 + parent.getDepth()
    }
}

//Could be algebrical datatype but still experimental in CodeQL
class LeafDataType extends Expr{
    LeafDataType() {
        this instanceof VarRef or
        this instanceof DotExpr or
        this instanceof Literal or
        (this instanceof ArrayExpr and forall(Expr member | this.(ArrayExpr).getAnElement() = member | member instanceof LeafDataType))
    }

    string getInitValue() {
        result = this.(VarRef).getName() or
        result = this.(DotExpr).getQualifiedName() or
        result = this.(Literal).getValue() or
        result = "[" + this.(ArrayExpr).getElement(0).(LeafDataType).getInitValue() + "]"
    }
}

class LeafMongoAttribute extends ASTNode{
    abstract string getFullyQualifiedName();
    abstract string getCollectionName();
    abstract string getType();
    abstract predicate isIndexed();
    abstract int getDepth();
}

//Non monotonic recursion prevention here
class LeafAttributeMongoose extends LeafMongoAttribute, Property {
    LeafAttributeMongoose() {
        ( this instanceof MongooseAttribute) and
        (this.getInit() instanceof MongooseTypeObject or this.getInit() instanceof LeafDataType) and
        not(exists(MongooseTypeObject typeObject | this.getObjectExpr() = typeObject))
    }
    MongooseSchemaS2 getSchema() {
        result = this.(MongooseAttribute).getSchema()
    }

    override string getCollectionName() {
        result = this.getSchema().getName()
    }
    override string getFullyQualifiedName() {
        result = this.(MongooseAttribute).getFullyQualifiedName()
    }
    override string getType() {
        result = this.(MongooseAttribute).getAttributeType()
    }

    override predicate isIndexed() {
        this.getInit().(MongooseTypeObject).isIndex()
    }

    override int getDepth() {
        result = this.(MongooseAttribute).getDepth()
    }

}

class BaseDocument extends ObjectExpr {
    abstract InsertQuery getBaseQuery();
}

class LeafInsertedAttribute extends LeafMongoAttribute {
    LeafInsertedAttribute() {
        this instanceof InsertedAttribute
    }
    override string getFullyQualifiedName() {
        result = this.(InsertedAttribute).getFullyQualifiedName()
    }
    override string getCollectionName() {
        result = this.(InsertedAttribute).getCollectionName()
    }
    override string getType() {
        result = this.(InsertedAttribute).getAttributeType()
    }

    override predicate isIndexed() {
        isStronglyIndexed(this.getFullyQualifiedName(), this.getCollectionName())
    }

    override int getDepth() {
        result = this.(InsertedAttribute).getDepth()
    }
}

abstract class InsertedAttribute extends MongoAttribute{

    abstract BaseDocument getBaseDocument();
}

class BaseDocumentAttribute extends InsertedAttribute, GenericAttribute {
    BaseDocument baseDocument;
    InsertQuery insertQuery;
    BaseDocumentAttribute() {
        this.getParent+() = baseDocument and
        baseDocument = insertQuery.getBaseDocument()
    }

    override BaseDocument getBaseDocument() {
        result = baseDocument
    }

    override string getFullyQualifiedName() {
        result = this.(GenericAttribute).getFullyQualifiedName()
    }

    override string getAttributeType() {
        if exists(this.getInit().analyze().getTheType())
        then result = this.getInit().analyze().getTheType().toString()
        else result = ""
    }

    override string getCollectionName() {
        result = insertQuery.getCollectionName()
    }

    override int getDepth() {
        result = this.(GenericAttribute).getDepth()
    }
}


class AttributeAccess extends InsertedAttribute, DotExpr {
    BaseDocument baseDocument;
    InsertQuery insertQuery;
    AssignExpr assignExpr;
    AttributeAccess() {
        exists(VariableDeclarator varDecl | varDecl.getInit() = baseDocument.getParent+()
        and this.getBase+() = varDecl.getBindingPattern().getAVariable().getAReference())
        and assignExpr.getLhs() = this
        and not exists(DotExpr parentDotExpr | parentDotExpr.getBase() = this)
        and baseDocument = insertQuery.getBaseDocument()
    }

    override BaseDocument getBaseDocument() {
        result = baseDocument
    }

    override string getFullyQualifiedName() {
        result = this.getQualifiedName().suffix(this.getQualifiedName().indexOf(".", 0, 0) + 1) 
    }

    override string getAttributeType() {
        if exists(assignExpr.getRhs().analyze().getTheType())
        then result = assignExpr.getRhs().analyze().getTheType().toString()
        else result = ""
    }
    override string getCollectionName() {
        result = insertQuery.getCollectionName()
    }

    override int getDepth() {
        result = count(this.getFullyQualifiedName().indexOf(".")) + 1
    }

}
abstract class MongoIndexDeclaration extends ASTNode {
    abstract string getCollectionName();
    abstract string getAQualifiedIndexName();
    abstract string getQualifiedIndexName();
}

class MongooseAttributeIndex extends MongoIndexDeclaration, LeafAttributeMongoose {
    MongooseAttributeIndex(){
        this.getInit().(MongooseTypeObject).isIndex()
    }

    override string getCollectionName() {
        result = this.getSchema().getName()
    }

    override string getAQualifiedIndexName() {
        result = this.getFullyQualifiedName()
    }
    override string getQualifiedIndexName() {
        result = this.getAQualifiedIndexName()
    }
}

abstract class MongoMethodIndexDeclaration extends MongoIndexDeclaration, MethodCallExpr {
    MongoMethodIndexDeclaration()
    {   respectAxioms(this) and
        recap(this)}
    override string getAQualifiedIndexName() {
        result = any(GenericLeafAttribute attr | attr.getParent+() = this.getArgument(0) | attr.getFullyQualifiedName())
    }    
    override string getQualifiedIndexName() {
        result = concat(GenericLeafAttribute attr | attr.getParent+() = this.getArgument(0) | attr.getFullyQualifiedName() , ",") 
    }


}
class MongooseIndexDeclaration extends MongoMethodIndexDeclaration {
    MongooseSchemaS2 schema;
    MongooseIndexDeclaration() {
        this.getMethodName() = "index" and
        exists(SchemaCompoundIndexConfiguration config| 
            config.hasFlow(schema.flow(), this.flow()))
    }
    override string getCollectionName() {
        result = schema.getName()
    }


}
class SchemaCompoundIndexConfiguration extends TaintTracking::Configuration {
    SchemaCompoundIndexConfiguration() { this = "SchemaCompoundIndexConfiguration" }
    
    override predicate isSource(DataFlow::Node node) {
        node.asExpr() instanceof MethodCallExpr
    }
    
    override predicate isSink(DataFlow::Node node) {
        exists(MethodCallExpr mce | mce.getReceiver() = node.asExpr())
    }
}

class MongoDBIndexDeclaration extends MongoMethodIndexDeclaration {
    MongoDBIndexDeclaration() {
        this.getMethodName() = "createIndex"

    }

    override string getCollectionName() {
        result = any( MongoDBCreateIndexCollectionCallConfiguration config, DataFlow::Node source, DataFlow::Node sink | 
            config.hasFlow(source, sink) and this.getReceiver() = sink.asExpr() | 
            source.asExpr().(MethodCallExpr).getArgument(0).(StringLiteral).getValue() )
        or
        result = this.getReceiver().(DotExpr).getPropertyName()
    
    }
        //3 is default value cfr https://www.mongodb.com/docs/manual/reference/collation-locales-defaults/#std-label-collation-default-paramsfds
    int getCollationStrength() {
        if exists(Property collation | collation.getParent*() = this.getArgument(1) and collation.getName() = "collation" and  exists(collation.getInit().(ObjectExpr).getPropertyByName("strength")))
        then result = any(Property collation | collation.getParent*() = this.getArgument(1) and collation.getName() = "collation" | collation.getInit().(ObjectExpr).getPropertyByName("strength").getInit().(NumberLiteral).getIntValue())
        else result = 3
    }
    predicate isCaseSensitive() {
        this.getCollationStrength() > 2
    }

}



class MongoDBCreateIndexCollectionCallConfiguration extends TaintTracking::Configuration {
    MongoDBCreateIndexCollectionCallConfiguration() {
        this="MongoDBCreateIndexCollectionCallConfiguration"
    }

    override predicate isSource(DataFlow::Node node) {
        exists(MethodCallExpr mce | mce = node.asExpr() and mce.getMethodName() = "collection")
    }
    override predicate isSink(DataFlow::Node node) {
        exists(MongoDBIndexDeclaration indexDecl | indexDecl.getReceiver() = node.asExpr())
    }
}


abstract class GenericAttribute extends Property {
    abstract string getFullyQualifiedName();
    abstract int getDepth();
}

class GenericFirstOrderAttribute extends GenericAttribute {
    GenericFirstOrderAttribute() {
        not exists(Property parentProp | parentProp.getInit() = this.getObjectExpr())
    }

    override string getFullyQualifiedName() {
        result = this.getName()
    }

    override int getDepth() {
        result = 1
    }
}

class GenericIntermediateAttribute extends GenericAttribute {
    GenericAttribute parent;

    GenericIntermediateAttribute() {
        this.getObjectExpr() = parent.getInit()
    }

    override string getFullyQualifiedName() {
        result = parent.getFullyQualifiedName() + "." + this.getName()
    }

    override int getDepth() {
        result = 1 + parent.getDepth()
    }

}

class GenericArrayAttribute extends GenericAttribute {
    GenericAttribute parent;

    GenericArrayAttribute() {
        this.getObjectExpr() = parent.getInit().(ArrayExpr).getAnElement()
    }

    override string getFullyQualifiedName() {
        result = parent.getFullyQualifiedName() + ".[" + this.getName() + "]"
    }
    override int getDepth() {
        result = 1 + parent.getDepth()
    }

}


class GenericLeafAttribute extends Property {
    GenericLeafAttribute()  {
        this instanceof GenericAttribute
        and this.getInit() instanceof LeafDataType
    }

    string getFullyQualifiedName() {
        result = this.(GenericAttribute).getFullyQualifiedName()
    }
}
 
predicate isStronglyIndexed(string fullyQualifiedName, string schemaName) {
    exists(LeafAttributeMongoose attr | attr.getFullyQualifiedName() = fullyQualifiedName and attr.getSchema().getName() = schemaName and attr.isIndexed()) or
    exists(MongoIndexDeclaration indexDecl | indexDecl.getQualifiedIndexName() = fullyQualifiedName and indexDecl.getCollectionName() = schemaName)
}

predicate isWeaklyIndexed(string fullyQualifiedName) {
    exists(LeafAttributeMongoose attr | attr.getFullyQualifiedName() = fullyQualifiedName and attr.isIndexed()) or
    exists(MongoIndexDeclaration indexDecl | indexDecl.getQualifiedIndexName() = fullyQualifiedName)

}

predicate isStronglyIndexedCaseSensitive(string fullyQualifiedName, string schemaName) {
    exists(LeafAttributeMongoose attr | attr.getFullyQualifiedName() = fullyQualifiedName and attr.getSchema().getName() = schemaName and attr.isIndexed() and attr.getSchema().isCaseSensitive()) or
    exists(MongoDBIndexDeclaration indexDecl | indexDecl.getQualifiedIndexName() = fullyQualifiedName and indexDecl.getCollectionName() = schemaName and indexDecl.isCaseSensitive())
}

predicate isWeaklyIndexCaseSensitive(string fullyQualifiedName) {
    exists(LeafAttributeMongoose attr | attr.getFullyQualifiedName() = fullyQualifiedName and attr.isIndexed() and attr.getSchema().isCaseSensitive()) or
    exists(MongoDBIndexDeclaration indexDecl | indexDecl.getQualifiedIndexName() = fullyQualifiedName and indexDecl.isCaseSensitive())
}