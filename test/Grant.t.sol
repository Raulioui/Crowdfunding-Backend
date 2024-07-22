// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Grant} from "../src/Grant/Grant.sol";
import {FactoryV2} from "../src/FactoryV2.sol";
import {GrantQueque} from "../src/Grant/GrantQueque.sol";

contract FactoryTest is Test {
    Grant public manager;
    GrantQueque public queque;
    FactoryV2 public factory;

    uint constant public REQUEST_STATUS = 0;
    uint constant public ACTIVE_STATUS = 1;
    uint constant public FINISHED_STATUS = 2;

    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    modifier createsAndApproveProyect() {
        vm.startPrank(user);
        vm.deal(user, 1e16);
        manager.sendProyectRequest{value: 1e16}("cid");
        vm.startPrank(address(1));
        queque.confirmTransaction(0);
        vm.startPrank(address(2));
        queque.confirmTransaction(0);
        vm.startPrank(address(3));
        queque.confirmTransaction(0);

        vm.startPrank(user2);
        vm.deal(user2, 1e16);
        manager.sendProyectRequest{value: 1e16}("cid");
        vm.startPrank(address(1));
        queque.confirmTransaction(1);
        vm.startPrank(address(2));
        queque.confirmTransaction(1);
        vm.startPrank(address(3));
        queque.confirmTransaction(1);
        _;
    }


    function setUp() public {
        factory = new FactoryV2();

        address[] memory ququeOwners = new address[](4);
        ququeOwners[0] = address(1);
        ququeOwners[1] = address(2);
        ququeOwners[2] = address(3);
        ququeOwners[3] = address(4);
        address pair = factory.deployGrant("cid", 2, ququeOwners, 3);
        manager = Grant(pair);
        queque = GrantQueque(manager.queque());
        vm.deal(address(this), 10 ether);
        manager.depositPoolFund{value: 10 ether}();
    }

    /**
     * @notice constructor
    */

    function testInitialize() public {
        assertEq(manager.managerAddress(), address(this));
        assertEq(manager.candidates(),2);
        assertEq(address(manager).balance,10 ether);
        assertEq(uint(manager.fundingStatus()), REQUEST_STATUS);
        assert(address(manager.queque()) != address(0));
    }

    /**
     * @notice sendProyectRequest
    */

   function testRevertsIfValueIsNotEnough() public {
        vm.expectRevert("Not enough funds");
        manager.sendProyectRequest{value: 0}("cid");
    }

    function testRevertsIfCidInEmpty() public {
        vm.expectRevert("Invalid cid");
        vm.deal(address(this), 1e16 ether);
        manager.sendProyectRequest{value: 1e16}("");
    }

    /**
     * @notice receiveApprovedProyect
    */

    function testRevertsIfProyectsAmountPassesTheMaximum() public {
        vm.deal(address(this), 3 ether);
        vm.startPrank(address(this));
        manager.sendProyectRequest{value: 1 ether}("cid");
        vm.startPrank(address(1));
        queque.confirmTransaction(0);
        vm.startPrank(address(2));
        queque.confirmTransaction(0);
        vm.startPrank(address(3));
        queque.confirmTransaction(0);

        vm.startPrank(address(this));
        manager.sendProyectRequest{value: 1 ether}("cid");
        vm.startPrank(address(1));
        queque.confirmTransaction(1);
        vm.startPrank(address(2));
        queque.confirmTransaction(1);
        vm.startPrank(address(3));
        queque.confirmTransaction(1);

        vm.startPrank(address(this));
        manager.sendProyectRequest{value: 1 ether}("cid");
        vm.startPrank(address(1));
        queque.confirmTransaction(2);
        vm.startPrank(address(2));
        queque.confirmTransaction(2);
        vm.startPrank(address(3));

        vm.expectRevert("Max number of candidates reached");
        queque.confirmTransaction(2);
    }

    function testRevertsIfTheCallerIsNotTheQueque() public {
        vm.expectRevert("Not allowed");
        manager.receiveApprovedProyect(address(this), "cid");
    }

    function testReceivesApprovedProyect() public createsAndApproveProyect{

        (address proyectOwner, uint256 numOfContributions, uint256 squaredRootedAmount, , uint256 proyectId, uint256 donationPower) = manager.proyects(0);

        assertEq(proyectOwner, address(user));
        assertEq(numOfContributions, 0);
        assertEq(squaredRootedAmount, 0);
        assertEq(proyectId, 0);
        assertEq(donationPower, 0);
    }

    /**
     * @notice donate
    */

   address donator = makeAddr("donator");

   function testRevertsIfGrantIsNotInActiveMode() public createsAndApproveProyect{
        vm.startPrank(donator);
        vm.deal(donator, 1 ether);
        vm.expectRevert("Funding is not active");
        manager.donate{value: 1 ether}(0);
   }

    function testRevertsIfTheProyectDoesNotExists() public createsAndApproveProyect{
        vm.startPrank(address(this));
        vm.warp(10 days);
        manager.endRequestPeriod();
        vm.startPrank(donator);
        vm.deal(donator, 1 ether);
        vm.expectRevert("Proyect does not exist");
        manager.donate{value: 1 ether}(2);
    }

    function testRevertsIfUserAlreadyDonated() public createsAndApproveProyect{
        vm.startPrank(address(this));
        vm.warp(10 days);
        manager.endRequestPeriod();
        vm.startPrank(donator);
        vm.deal(donator, 2 ether);
        manager.donate{value: 1 ether}(0);
        vm.expectRevert("You already donated to this proyect");
        manager.donate{value: 1 ether}(0);
    }

   function testRevertsIfOwnerDonatedToHisProyect() public createsAndApproveProyect{
        vm.warp(10 days);
        vm.startPrank(address(this));
        manager.endRequestPeriod();
        vm.startPrank(address(user));
        vm.deal(address(user), 2 ether);
        vm.expectRevert("You can't donate to your own proyect");
        manager.donate{value: 1 ether}(0);
   }

    function testDonates() public createsAndApproveProyect{
        address userDonation = makeAddr("donator2");
        vm.warp(10 days);
        vm.startPrank(address(this));
        manager.endRequestPeriod();

        vm.startPrank(userDonation);
        vm.deal(userDonation, 2 ether);

        manager.donate{value: 1 ether}(0);
        manager.donate{value: 1 ether}(1);
        vm.stopPrank();
        (, uint256 numOfContributions, uint256 squaredRootedAmount,uint256 donationAmount , , ) = manager.proyects(0);
        
        assertEq(numOfContributions, 1);
        uint256 expectedDonationAmount = _sqrt(1_000_000_000_000_000_000);
        assertEq(squaredRootedAmount, expectedDonationAmount);
        assertEq(donationAmount, 1 ether);
        assertEq(expectedDonationAmount * expectedDonationAmount, 1 ether);
        vm.startPrank(address(this));
        vm.warp(40 days);
        manager.distributeFunds();
    }

    /**
     * @notice endRequestPeriod
    */

    function testRevertIfRequestPeriodHasNotEnded() public {
        vm.expectRevert("Request period has not ended");
        manager.endRequestPeriod();
    }

    function testRevertIfCandidatesAreNotTheRequired() public {
        vm.expectRevert("Not enough candidates");
        vm.warp(40 days);
        manager.endRequestPeriod();
    }

    function testEndRequestPeriod() public createsAndApproveProyect{
        vm.warp(40 days);
        vm.startPrank(address(this));
        manager.endRequestPeriod();
        assertEq(uint(manager.fundingStatus()), ACTIVE_STATUS);
    }

    /**
     * @notice distributeFunds
    */

   function testRevertsIfFundingPeriodHasNotEnded() public createsAndApproveProyect{
        vm.startPrank(address(this));
        vm.warp(10 days);
        manager.endRequestPeriod();
        vm.expectRevert("Funding period has not ended");
        manager.distributeFunds();
    }

    function testDistributeFunds() public createsAndApproveProyect{
        address userDonation = makeAddr("donator");
       
        vm.warp(10 days);
        vm.startPrank(address(this));
        manager.endRequestPeriod();

        vm.startPrank(userDonation);
        vm.deal(userDonation, 2 ether);

        manager.donate{value: 1 ether}(0);
        manager.donate{value: 1 ether}(1);
        uint256 contractBalanceStart = address(manager).balance;


        vm.warp(40 days);
        vm.startPrank(address(this));
        manager.distributeFunds();
        assertEq(address(user).balance + address(user2).balance, contractBalanceStart);
        assertEq(address(manager).balance, 0);
    }

    function _sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

} 