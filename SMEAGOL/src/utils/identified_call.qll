import javascript
import mongodb.mongoRecap
import mongoose.mongooseRecap
import axioms
import codeGen
import blackList

predicate mongooseCall(MethodCallExpr mce) {
    mongooseMethodName(mce.getMethodName()) and
    respectAxioms(mce) and
    recap(mce)
}

predicate mongoDBCall(MethodCallExpr mce) {
    mongoMethodName(mce.getMethodName()) and
    respectAxioms(mce) and
    recap(mce)
}

predicate isAMongoCall(MethodCallExpr mce) {
    mongooseCall(mce) or mongoDBCall(mce)
}