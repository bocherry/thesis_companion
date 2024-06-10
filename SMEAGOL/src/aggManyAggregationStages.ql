/**
 * @name Too many aggregation stages
 * @id aggManyAggregationStages
 * @kind problem
 * @description Detects how many stages are used inside a aggregation pipeline
 */

import javascript
import utils.aggregateCall


from AggregateCall aggregatecall
select aggregatecall, "You have " + aggregatecall.getAggregationStagesNumber() + " aggregation stages"