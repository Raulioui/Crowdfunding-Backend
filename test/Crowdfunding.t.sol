// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/Crowdfunding.sol";
import {Voting} from "./Factory.t.sol";

contract FactoryTest is Test {
    CrowdFunding crowdfunding;  
    Voting voting;

    uint16 public constant WITHDRAW_FEE = 95;
    uint16 public constant MAX_VOTINGS = 5;
    uint256 constant public VOTE_VALUE = 10**6;

    string constant name = "name";
    string constant description = "description";    
    uint256 constant target = 100000;
    string constant categorie = "categorie";
    uint256 constant timeLimit = 10304034;
    string constant imageCid = "imageCid";

    function setUp() public {
        crowdfunding = new CrowdFunding();
        voting = new Voting();
    }

    modifier crowdfundingInitialized() {
        crowdfunding.initialize(
            target,
            address(1),
            timeLimit,
            address(voting)
        );
        _;
    }


    function testInitialize() public crowdfundingInitialized{

        assertEq(crowdfunding.target(), target);
        assertEq(crowdfunding.contractOwner(), address(1));
        assertEq(crowdfunding.closingDate(), timeLimit);
        assertEq(crowdfunding.implementationContract(), address(voting));
        assertEq(crowdfunding.amountCollected(), 0);
        assertEq(crowdfunding.isCompleted(), false);
    }

    function testOwnerCantDonate() public crowdfundingInitialized {
        vm.expectRevert("The owner can't donate");
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        crowdfunding.donate{value: 100}("message");
    }

    function testCantDonateIfIsCompleted() public crowdfundingInitialized {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: target }("message");

        vm.expectRevert("The crowdfunding is completed");

        crowdfunding.donate{value: 1000}("message");
    }

    function testCantDonateIfValueIs0() public crowdfundingInitialized {
        vm.expectRevert("Insuficient amount");
        vm.startPrank(address(2));

        crowdfunding.donate{value: 0}("message");
    }

    function testDonate() public crowdfundingInitialized {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: target}("message");

        assertEq(crowdfunding.amountCollected(), target);
        assertEq(crowdfunding.isCompleted(), true);
        assertEq(crowdfunding.donations(address(2)), target);
        assertEq(crowdfunding.percentage(address(2)), 100);
    }

    function testUserCantWithdrawIfIsCompleted() public crowdfundingInitialized {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: target}("message");

        vm.expectRevert("The crowdfunding is completed");

        crowdfunding.withdrawUser();
    }

    function testUserCantWithdrawIfCrowdfundingIsExpired() public  crowdfundingInitialized{
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: 100}("message");

        vm.warp(20304034000);

        vm.expectRevert("The crowdfunding is closed");

        crowdfunding.withdrawUser();
    }

    function testUserCantWithdrawIfDontHaveFunds() public crowdfundingInitialized {
        vm.startPrank(address(2));
       
        vm.expectRevert("You don't have any funds");

        crowdfunding.withdrawUser();
    }

    function testUserWithdraw() public crowdfundingInitialized {
        vm.startPrank(address(2));
        vm.deal(address(2), 100);

        crowdfunding.donate{value: 100}("message");

        uint256 penaltyAmount = (100 * WITHDRAW_FEE) / 100;
        uint256 feeAmount = 100 - penaltyAmount;

        crowdfunding.withdrawUser();

        assertEq(address(2).balance, penaltyAmount);
        assertEq(crowdfunding.amountCollected(), feeAmount);
        assertEq(crowdfunding.donations(address(2)), 0);
        assertEq(crowdfunding.percentage(address(2)), 0);
    }

    function testUserCantWithdrawTheCrowdfunding() public crowdfundingInitialized {
        vm.startPrank(address(2));

        vm.expectRevert("You're not the owner");

        crowdfunding.withdrawOwner();
    }

    function testOwnerCantWithdraIfCrowdfundingIsNotExpired() public crowdfundingInitialized {
        vm.startPrank(address(1));

        vm.expectRevert("The crowdfunding isn't closed");

        crowdfunding.withdrawOwner();
    }

    function testOwnerCanWithdrawIfTheTargetIsPassed() public crowdfundingInitialized{
        vm.startPrank(address(2));
        vm.deal(address(2), 200000);

        crowdfunding.donate{value: target}("message");

        vm.stopPrank();
        vm.startPrank(address(1));
        crowdfunding.withdrawOwner();

        assertEq(address(1).balance, target);
        assertEq(crowdfunding.amountCollected(), 0);
    }

    function testOwnerWithdraw() public crowdfundingInitialized {
        vm.startPrank(address(2));
        vm.deal(address(2), 100);

        crowdfunding.donate{value: 100}("message");

        vm.warp(20304034000);
        
        vm.stopPrank();
        vm.startPrank(address(1));

        crowdfunding.withdrawOwner();

        assertEq(address(1).balance, 100);
        assertEq(crowdfunding.amountCollected(), 0);
        assertEq(crowdfunding.isCompleted(), true);
    }

    function cantCreateMoreThanFiveVotings() public crowdfundingInitialized {
        vm.startPrank(address(1));
        crowdfunding.createVoting("test");
        crowdfunding.createVoting("test");
        crowdfunding.createVoting("test");
        crowdfunding.createVoting("test");
        crowdfunding.createVoting("test");
        vm.expectRevert("You can't create more votings");
        crowdfunding.createVoting("test");
    }

    function testCantCreateVotingIfIsCompleted() public crowdfundingInitialized {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: target}("message");

        vm.expectRevert("The crowdfunding is completed");

        vm.startPrank(address(1));
        crowdfunding.createVoting("test");
    }

    function testCantCreateVotingIfNotOwner() public crowdfundingInitialized {
        vm.startPrank(address(2));

        vm.expectRevert("You are not the owner");

        crowdfunding.createVoting("test");
    }

    function testCreatesVotingAndVote() public crowdfundingInitialized {
        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("test");

        vm.assume(pair != address(0));
    
        assertEq(crowdfunding.votingContracts(0), pair);

        Voting _voting = Voting(pair);

        assertEq(_voting.votes(), 0);
        assertEq(_voting.yesVotes(), 0);
        assertEq(_voting.noVotes(), 0);
        vm.assume(_voting.timeLimit() > block.timestamp);
        assertEq(_voting.owner(), address(1));

        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdfunding.donate{value: 1000}("message");
        crowdfunding.vote(1, pair);
        
        assertEq(_voting.votes(), 1);
        assertEq(_voting.yesVotes(), 100 * VOTE_VALUE);
    }

    function testCantVoteIfThePairIsNotValid() public crowdfundingInitialized {
        vm.startPrank(address(1));
        vm.expectRevert("The voting doesn't exist");
        crowdfunding.vote(1, address(1));
    }

    function testCantVoteIfDontDonate() public crowdfundingInitialized {
        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("test");

        vm.startPrank(address(2));
        vm.expectRevert("You're not allowed to vote");
        crowdfunding.vote(1, pair);
    }


    function testCantVoteIfCrowdfundingHasExpired() public crowdfundingInitialized {
        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("voting");
        vm.stopPrank();
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdfunding.donate{value: 1000}("message");
        vm.warp(20304034000);
        vm.expectRevert("The voting is close");
        crowdfunding.vote(1, pair);
    }

    function testCantVoteIfNumberIsInvalid() public crowdfundingInitialized {
        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("voting");
        vm.stopPrank();
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdfunding.donate{value: 1000}("message");
        vm.expectRevert("Invalid vote");
        crowdfunding.vote(2, pair);
    }

    function testCantVoteTwice() public crowdfundingInitialized {
        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("voting");
        vm.stopPrank();
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdfunding.donate{value: 1000}("message");
        crowdfunding.vote(1, pair);
        vm.expectRevert("You already voted");
        crowdfunding.vote(1, pair);
    }

    function testVote() public crowdfundingInitialized {
        vm.startPrank(address(1));
        address pair = crowdfunding.createVoting("voting");
        vm.stopPrank();
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdfunding.donate{value: 1000}("message");
        crowdfunding.vote(1, pair);

        assertEq(crowdfunding.hasVoted(address(2), pair), true);

        Voting _voting = Voting(pair);

        assertEq(_voting.votes(), 1);
        assertEq(_voting.yesVotes(), 100 * VOTE_VALUE);
        
    }

}
