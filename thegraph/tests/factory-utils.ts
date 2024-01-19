import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import { fundingContractCreated } from "../generated/Factory/Factory"

export function createfundingContractCreatedEvent(
  pair: Address,
  owner: Address,
  name: string,
  description: string,
  target: BigInt,
  categorie: string,
  timeLimit: BigInt,
  imageCid: string
): fundingContractCreated {
  let fundingContractCreatedEvent = changetype<fundingContractCreated>(
    newMockEvent()
  )

  fundingContractCreatedEvent.parameters = new Array()

  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam("pair", ethereum.Value.fromAddress(pair))
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam("name", ethereum.Value.fromString(name))
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "description",
      ethereum.Value.fromString(description)
    )
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam("target", ethereum.Value.fromUnsignedBigInt(target))
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam("categorie", ethereum.Value.fromString(categorie))
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "timeLimit",
      ethereum.Value.fromUnsignedBigInt(timeLimit)
    )
  )
  fundingContractCreatedEvent.parameters.push(
    new ethereum.EventParam("imageCid", ethereum.Value.fromString(imageCid))
  )

  return fundingContractCreatedEvent
}
