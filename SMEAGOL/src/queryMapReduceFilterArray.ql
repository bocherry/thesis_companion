/**
 * @name Using $map, $reduce and $filter with array fields
 * @description Avoid using $map, $filter and $reduce while working with array fields as they are slower than their projection counterpart
 * @kind alert
 * @id queryMapReduceFilterArray
 */

 import javascript
 import utils.aggregateCall

 from AggregateCall aggregate
 where 
    exists(ObjectExpr stage, string stageName | 
        aggregate.getAStageByName(stageName) = stage and
        stageName in ["$map", "$reduce", "filter"])
select aggregate, "This aggregate uses a $map/$reduce/$filter operator. Consider avoiding it as it is slower than its projection counterpart"