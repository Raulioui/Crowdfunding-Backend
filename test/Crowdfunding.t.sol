// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/Crowdfunding/Crowdfunding.sol";
import {Queque} from "../src/Crowdfunding/Queque.sol";

contract FactoryTest is Test {
     
    CrowdFunding crowdfunding;  
    Queque queque;

    uint16 public constant WITHDRAW_FEE = 95;
  
    uint256 constant target = 100000;

    address user = makeAddr("user");
    uint256 public constant FROM_GWEI_TO_WEI = 1e9;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);

        queque = new Queque(owners, 2);
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        queque.createRequest{value: 1 ether}("cid", 100, block.timestamp + 20 days);
        vm.startPrank(address(1));
        queque.confirmTransaction(0);
        vm.startPrank(address(2));
        queque.confirmTransaction(0);

        address pair = queque.proyectsExecuted(0);
        crowdfunding = CrowdFunding(pair);
    }
 
    /**
     * @notice Constructor
    */

    function testInitialize() public{
        assertEq(crowdfunding.target(), 100 * FROM_GWEI_TO_WEI);
        assertEq(crowdfunding.owner(), address(user));
        assertEq(crowdfunding.cid(), "cid");
        assertEq(crowdfunding.amountCollected(), 0);
        assert(crowdfunding.deployerAddress() != address(0));
    }

    /**
     * @notice Donate
    */

    function testOwnerCantDonate() public {
        vm.expectRevert("The owner can't donate");
        vm.startPrank(user);
        vm.deal(user, 1 ether);

        crowdfunding.donate{value: 100}("message");
    }

    function testCantDonateIfIsCompleted() public {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: 10000000000000 }("message");

        vm.expectRevert("The crowdfunding is completed");

        crowdfunding.donate{value: 1000}("message");
    }

    function testCantDonateIfValueIs0() public {
        vm.expectRevert("Insuficient amount");
        vm.startPrank(address(2));

        crowdfunding.donate{value: 0}("message");
    }

    function testDonate() public {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: 100000000000000}("message");


        assertEq(crowdfunding.amountCollected(), 100000000000000);
        assertEq(crowdfunding.isCompleted(), true);
        assertEq(crowdfunding.donations(address(2)), 100000000000000);
    }

    /**
     * @notice withdrawUser
    */

    function testUserCantWithdrawIfIsCompleted() public {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: target * FROM_GWEI_TO_WEI}("message");

        vm.expectRevert("The crowdfunding is completed");

        crowdfunding.withdrawUser();
    }

    function testUserCantWithdrawIfCrowdfundingIsExpired() public {
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);

        crowdfunding.donate{value: 50}("message");

        vm.warp(20304034000);

        vm.expectRevert("The crowdfunding is closed");

        crowdfunding.withdrawUser();
    }

    function testUserCantWithdrawIfDontHaveFunds() public {
        vm.startPrank(address(2));
       
        vm.expectRevert("You don't have any funds");

        crowdfunding.withdrawUser();
    }

    function testUserWithdraw() public {
        vm.startPrank(address(2));
        vm.deal(address(2), 50);

        crowdfunding.donate{value: 50}("message");

        uint256 penaltyAmount = (50 * WITHDRAW_FEE) / 100;
        uint256 feeAmount = 50 - penaltyAmount;

        crowdfunding.withdrawUser();

        assertEq(address(2).balance, penaltyAmount);
        assertEq(crowdfunding.amountCollected(), feeAmount);
        assertEq(crowdfunding.donations(address(2)), 0);
    }

    /**
     * @notice withdrawOwner
    */


    function testUserCantWithdrawTheCrowdfunding() public {
        vm.startPrank(address(2));

        vm.expectRevert("You're not the owner");

        crowdfunding.withdrawOwner();
    }

    function testOwnerCantWithdraIfCrowdfundingIsNotExpired() public {
        vm.startPrank(user);

        vm.expectRevert("The crowdfunding isn't closed");

        crowdfunding.withdrawOwner();
    }

    function testOwnerCanWithdrawIfTheTargetIsPassed() public{
        vm.startPrank(address(2));
        vm.deal(address(2), 2 ether);

        crowdfunding.donate{value: target * FROM_GWEI_TO_WEI}("message");

        vm.stopPrank();
        vm.startPrank(user);
        crowdfunding.withdrawOwner();

        assertEq(user.balance, target * FROM_GWEI_TO_WEI);
        assertEq(crowdfunding.amountCollected(), 0);
    }

    function testOwnerWithdraw() public {
        vm.startPrank(address(2));
        vm.deal(address(2), 100);

        crowdfunding.donate{value: 100}("message");

        vm.warp(20304034000);
        
        vm.stopPrank();
        vm.startPrank(user);

        crowdfunding.withdrawOwner();

        assertEq(user.balance, 100);
        assertEq(crowdfunding.amountCollected(), 0);
        assertEq(crowdfunding.isCompleted(), true);
    }

}
