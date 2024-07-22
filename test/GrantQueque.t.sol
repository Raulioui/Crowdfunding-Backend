// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Grant} from "../src/Grant/Grant.sol";
import {GrantQueque} from "../src/Grant/GrantQueque.sol";

contract MultiSignTest is Test {
    Grant public manager;
    GrantQueque public queque;

    address ownerOne = makeAddr("ownerOne");
    address ownerTwo = makeAddr("ownerTwo");
    address ownerThree = makeAddr("ownerThree");
    address ownerFour = makeAddr("ownerFour");

    modifier createsRequest() {
        vm.startPrank(address(manager));
        queque.createRequest(address(9), "cid");
        _;
    }

    function setUp() public {
        address[] memory ququeOwners = new address[](4);
        ququeOwners[0] = ownerOne;
        ququeOwners[1] = ownerTwo;
        ququeOwners[2] = ownerThree;
        ququeOwners[3] = ownerFour;
        manager = new Grant(2, ququeOwners, 3, address(this), "cid");
        queque = GrantQueque(address(manager.queque()));
    }

    /**
     * @notice constructor
    */

   function testConstructor() public {
        assertEq(queque.owners(0), ownerOne);
        assertEq(queque.owners(1), ownerTwo);
        assertEq(queque.owners(2), ownerThree);
        assertEq(queque.owners(3), ownerFour);
        assertEq(queque.confirmationsRequired(), 3);
        assertEq(queque.grantAddress(), address(manager));
    }

    /**
     * @notice createRequest
    */

    function testRevertsIfCallerIsNotManager() public {
        vm.startPrank(ownerOne);
        vm.expectRevert("Not allowed");
        queque.createRequest(address(9), "cid");
    }

    function testCreatesRequest() public {
        vm.startPrank(address(manager));
        queque.createRequest(address(9), "cid");

        (bytes32 cid, address owner, bool executed) = queque.proyectsInQueque(0);

        assertEq(cid, "cid");
        assertEq(owner, address(9));
        assertEq(executed, false);
    }

    /**
     * @notice confirmTransition
    */

    function testRevertsIfCallerIsNotOwner() public createsRequest{
        vm.startPrank(address(9));
        vm.expectRevert("Not owner");
        queque.confirmTransaction(0);
    }

    function testRevertsIfProyectDoesNotExist() public {
        vm.startPrank(ownerOne);
        vm.expectRevert("Invalid id");
        queque.confirmTransaction(1);
    }

    function testRevertsIfOwnerAlreadyApproved() public createsRequest {
        vm.startPrank(ownerOne);
        queque.confirmTransaction(0);
        vm.startPrank(ownerOne);
        vm.expectRevert("Already approved");
        queque.confirmTransaction(0);
    }

    function testRevertsIfTheProyectHasBeenExecuted() public createsRequest{
        vm.startPrank(ownerOne);
        queque.confirmTransaction(0);
        vm.startPrank(ownerTwo);
        queque.confirmTransaction(0);
        vm.startPrank(ownerThree);
        queque.confirmTransaction(0);
        vm.startPrank(ownerFour);
        vm.expectRevert("Transaction already executed");
        queque.confirmTransaction(0);
    }

    function testConfirmTransaction() public createsRequest {
        vm.startPrank(ownerOne);
        queque.confirmTransaction(0);
        vm.startPrank(ownerTwo);
        queque.confirmTransaction(0);
        vm.startPrank(ownerThree);
        queque.confirmTransaction(0);

        (, , bool executed) = queque.proyectsInQueque(0);
        assertEq(executed, true);
    }
}
