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
            "name",
            "description",
            0,
            "categorie",
            10304034000,
            "imageCid"
        );
    }

    function testCreatesCrowdfundingAndInitializes() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        (address pair) = factory.createCrowdFunding(
            "nam",
            "desc",
            100000,
            "cat",
            10304034,
            "image"
        );

       // CrowdFunding proxy = new CrowdFunding(pair);
        
        vm.assume(pair != address(0));

        CrowdFunding proxy = CrowdFunding(pair);

        uint256 FROM_GWEI_TO_WEI = 1e9;

        assertEq(proxy.target(), 100000 * FROM_GWEI_TO_WEI);
        assertEq(proxy.amountCollected(), 0);
        assertEq(proxy.contractOwner(), address(1));
        assertEq(proxy.isCompleted(), false);
        assertEq(proxy.closingDate(), 10304034);
        assertEq(proxy.implementationContract(), voting);

        vm.stopPrank();
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        proxy.donate{value: 1000 wei}("Helloooo");
        assertEq(proxy.amountCollected(), 1000);
        vm.stopPrank(); 
    }
}
