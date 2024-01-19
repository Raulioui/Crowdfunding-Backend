/* // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";
import {CrowdFunding} from "../src/Crowdfunding.sol";

contract FactoryTest is Test {
    Voting voting;
    CrowdFunding crowdfunding;  

    function setUp() public {
        voting = new Voting();
        crowdfunding = new CrowdFunding();
    }

    modifier crowdfundingInitialized() {
        voting.initialize(
            address(1)
        );
        _;
    }

    function testInitialize() public crowdfundingInitialized{
        assertEq(voting.owner(), address(1));
        assertEq(voting.votes(), 0);
        assertEq(voting.yesVotes(), 0);
        assertEq(voting.noVotes(), 0);
        assertEq(voting.hasEnded(), false);
    }

    function testCantVoteIfIsOwner() public crowdfundingInitialized {
        vm.expectRevert("The owner is not allowed to vote");
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        voting.vote(1);
    }

    function testCantVoteIfYouDOntDonate () public crowdfundingInitialized {
        vm.expectRevert("You're not allowed to vote");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        voting.vote(1);
    }

    function testCantDonateIfTimeLimitIsOver() public crowdfundingInitialized {
        vm.expectRevert("The voting is close");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        vm.warp(20304034000);

        voting.vote(1);
    }

    function testCantDonateIfVoteIsInvalid() public crowdfundingInitialized {
        vm.expectRevert("Invalid vote");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        voting.vote(2);
    }

    function testCantDonateIfAlreadyVoted() public crowdfundingInitialized {
        
        vm.startPrank(address(3));
        vm.deal(address(3), 1 ether);

        voting.vote(1);
        vm.expectRevert("You already voted");
        voting.vote(1);
    }

    function testVoted () public  {
        vm.startPrank(address(1));
        crowdfunding.initialize(
            100000,
            address(1),
            10304034000,
            address(voting)
        );

        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdfunding.donate{value: 10000}("message");

        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("test", "test");

        Voting _voting = Voting(pair);

        vm.startPrank(address(2));

       
        voting.vote(1);
        assertEq(voting.votes(), 1);
        assertEq(voting.yesVotes(), 5 * 10**6);
        assertEq(voting.noVotes(), 0);
        assertEq(voting.hasVoted(address(3)), true);
    }

    function testCantCloseVotingIfIsNotOwner() public crowdfundingInitialized {
        vm.expectRevert("You are not the owner");
        vm.startPrank(address(3));
        vm.deal(address(3), 1 ether);

        voting.closeVoting();
    }

    function testCantCloseVotingIfTimeLimitIsNotOver() public crowdfundingInitialized {
        vm.expectRevert("The voting has not ended");
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        voting.closeVoting();
    }

    function testCantCloseIfOwnerAlreadyClosed() public crowdfundingInitialized {
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);
        vm.warp(20304034000);

        voting.closeVoting();
        vm.expectRevert("You already close the voting");
        voting.closeVoting();
    }

    function testCloseVoting() public crowdfundingInitialized {
        vm.startPrank(address(2));
        voting.vote(1);
        vm.stopPrank();

        vm.startPrank(address(1));
        vm.warp(20304034000);

        voting.closeVoting();
        assertEq(voting.hasEnded(), true);
        assertEq(voting.votes(), 1);
        assertEq(voting.yesVotes(), 5 * 10**6);
        assertEq(voting.noVotes(), 0);
    }
} */