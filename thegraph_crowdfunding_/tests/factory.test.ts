import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { fundingContractCreated } from "../generated/schema"
import { fundingContractCreated as fundingContractCreatedEvent } from "../generated/Factory/Factory"
import { handlefundingContractCreated } from "../src/factory"
import { createfundingContractCreatedEvent } from "./factory-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let pair = Address.fromString("0x0000000000000000000000000000000000000001")
    let owner = Address.fromString("0x0000000000000000000000000000000000000001")
    let name = "Example string value"
    let description = "Example string value"
    let target = BigInt.fromI32(234)
    let categorie = "Example string value"
    let timeLimit = BigInt.fromI32(234)
    let imageCid = "Example string value"
    let newfundingContractCreatedEvent = createfundingContractCreatedEvent(
      pair,
      owner,
      name,
      description,
      target,
      categorie,
      timeLimit,
      imageCid
    )
    handlefundingContractCreated(newfundingContractCreatedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("fundingContractCreated created and stored", () => {
    assert.entityCount("fundingContractCreated", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "pair",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "owner",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "name",
      "Example string value"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "description",
      "Example string value"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "target",
      "234"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "categorie",
      "Example string value"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "timeLimit",
      "234"
    )
    assert.fieldEquals(
      "fundingContractCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "imageCid",
      "Example string value"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
