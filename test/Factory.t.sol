// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {CrowdFunding} from "../src/Crowdfunding.sol";
import {Voting} from "../src/Voting.sol";

contract FactoryTest is Test {
    Factory factory;
    address crowdfunding;  
    address voting;

    string constant name = "name";
    string constant description = "description";    
    uint256 constant target = 100000;
    string constant categorie = "categorie";
    uint256 constant timeLimit = 10304034;
    string constant imageCid = "imageCid";

    event fundingContractCreated (
        address indexed pair,
        address indexed owner,
        string name,
        string description,
        uint256 target,
        string indexed categorie,
        uint256 timeLimit,
        string imageCid
    );


    function setUp() public {
        factory = new Factory();
        voting = factory.implementationVotingContract();
        crowdfunding = factory.implementationCrowdfundingContract();
    }

    function testCantEnterTargetIs0() public {
        vm.expectRevert("Insuficient target");

        factory.createCrowdFunding(
            name,
            description,
            0,
            categorie,
            timeLimit,
            imageCid
        );
    }

    function testCreatesCrowdfundingAndInitializes() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        (address pair) = factory.createCrowdFunding(
            name,
            description,
            target,
            categorie,
            timeLimit,
            imageCid
        );
        
        vm.assume(pair != address(0));

        CrowdFunding proxy = CrowdFunding(pair);

        uint256 FROM_GWEI_TO_WEI = 1e9;

        assertEq(proxy.target(), target * FROM_GWEI_TO_WEI);
        assertEq(proxy.amountCollected(), 0);
        assertEq(proxy.contractOwner(), address(1));
        assertEq(proxy.isCompleted(), false);
        assertEq(proxy.closingDate(), timeLimit);
        assertEq(proxy.implementationContract(), voting);

        vm.stopPrank();
    }
}
