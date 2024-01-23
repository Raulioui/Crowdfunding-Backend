// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";
import {CrowdFunding} from "../src/Crowdfunding.sol";

contract FactoryTest is Test {
    Voting voting;
    CrowdFunding crowdfunding;  

    uint256 constant public VOTE_VALUE = 10**6;

    function setUp() public {
        voting = new Voting();
        crowdfunding = new CrowdFunding();
    }

    modifier crowdfundingInitialized() {
        voting.initialize(
            address(1),
            address(crowdfunding)
        );
        _;
    }

    function testInitialize() public crowdfundingInitialized{
        assertEq(voting.owner(), address(1));
        assertEq(voting.votes(), 0);
        assertEq(voting.yesVotes(), 0);
        assertEq(voting.noVotes(), 0);
    }

    function testSenderHasToBeCrowdfundingContract() public crowdfundingInitialized {
        vm.expectRevert("You're not allowed to vote");
        vm.startPrank(address(1));
        voting.vote(0, 100);
    }

    function testVote() public crowdfundingInitialized {
        vm.startPrank(address(crowdfunding));
        voting.vote(0, 100);
        uint256 yesVotes = 100 * VOTE_VALUE;
        assertEq(voting.votes(), 1);
        assertEq(voting.noVotes(), yesVotes);
        assertEq(voting.yesVotes(), 0);
    }
} 