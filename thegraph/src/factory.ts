import { fundingContractCreated as fundingContractCreatedEvent } from "../generated/Factory/Factory"
import { fundingContractCreated } from "../generated/schema"

export function handlefundingContractCreated(
  event: fundingContractCreatedEvent
): void {
  let entity = new fundingContractCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.pair = event.params.pair
  entity.owner = event.params.owner
  entity.name = event.params.name
  entity.description = event.params.description
  entity.target = event.params.target
  entity.categorie = event.params.categorie
  entity.timeLimit = event.params.timeLimit
  entity.imageCid = event.params.imageCid

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
