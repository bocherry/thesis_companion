/**
 * @name Lookup without supporting indexes
 * @id aggLookupWoIndexWeak
 * @kind problem
 * @description Detects whether a lookup is used without a matching index (with strong index insurance)
 */

import javascript
import utils.aggregateCall
import utils.schema_inference_internal

from AggregateCall aggregate
where exists(aggregate.getAStageByName("$lookup"))
and not isStronglyIndexed(aggregate.getAStageByName("$lookup").getPropertyByName("localField").getInit().(StringLiteral).getValue(), aggregate.getBaseCollectionName())
select aggregate, "This aggregate performs a lookup on an attribute not strongly indexed. This can cause a drop in aggregate performance"