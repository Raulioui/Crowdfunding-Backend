// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Queque} from "../src/Crowdfunding/Queque.sol";

contract QuequeTest is Test {
    Queque public queque;

    uint constant public MAX_OWNER_COUNT = 5;
    uint256 public constant REQUEST_PRICE = 1e16; // 0.01 ether
    uint256 public constant FROM_GWEI_TO_WEI = 1e9;
       
    address user = makeAddr("user");

    modifier createRequest() {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        uint256 _timeLimit = block.timestamp + 20 days;
        queque.createRequest{value: 1 ether}("cid", 100, _timeLimit);
        _;
    }

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);

        queque = new Queque(owners, 2);
    }

    /**
     * @notice Constructor
    */

    function testRevertIfArrayLenghtOverpasses() public {
        address[] memory owners = new address[](MAX_OWNER_COUNT + 1);

        vm.expectRevert("Invalid number of owners");
        Queque _wallet = new Queque(owners, 2);
    }
    
    function testRevertIfConfirmationsNumberIsZero() public {
        vm.expectRevert("Invalid number of confirmations");
        Queque _wallet = new Queque(new address[](3), 0);
    }

    function testRevertIfConfirmationsNumberHigh() public {
        address[] memory owners = new address[](3);
        owners[0] = address(5);
        owners[1] = address(6);
        owners[2] = address(7);
        vm.expectRevert("Invalid number of confirmations");
        Queque _wallet = new Queque(owners, 5);
    }

    function testRevertIfAddressIsInvalid() public {
        address[] memory owners = new address[](3);
        owners[0] = address(0);
        vm.expectRevert("Invalid address provided");
        Queque _wallet = new Queque(owners, 2);
    }

    function testRevertIfAddressIsDuplicated() public  {
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(1);
        owners[2] = address(3);

        vm.expectRevert("Duplicate owner");
        Queque _wallet = new Queque(owners, 2);
    }

    function testInitializeWallet() public {
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);

        Queque _wallet = new Queque(owners, 2);

        assertEq(_wallet.owners(0), address(1));
        assertEq(_wallet.owners(1), address(2));
        assertEq(_wallet.owners(2), address(3));

        assertEq(_wallet.isOwner(address(1)), true);
        assertEq(_wallet.isOwner(address(2)), true);
        assertEq(_wallet.isOwner(address(3)), true);
        assertEq(_wallet.confirmationsRequired(), 2);
    }

    /**
     * @notice createCrowdFundingRequest
    */

   function testRevertsIfValueIsLessThanRequestPrice() public {
        vm.expectRevert("Insuficient amount");
        queque.createRequest{value: 0}("cid", 100, 10000000000000);
    }

    function testRevertsIfCidIsEmpty() public {
        vm.expectRevert("Invalid cid");
        queque.createRequest("", 100, 100);
    }  

    function testRevertsIfTargetIsZero() public {
        vm.expectRevert("Insuficient target");
        queque.createRequest("cid", 0, 100);
    } 

    function testCreatesCrowdfundingRequest() public createRequest{

        (bytes32 crfCid, uint256 target,address owner,  uint256 timeLimit, bool executed) = queque.proyectsInQueque(0);

        uint256 _timeLimit = block.timestamp + 20 days;

        assertEq(owner, address(user));
        assertEq(crfCid, "cid");
        assertEq(target, 100 * FROM_GWEI_TO_WEI);
        assertEq(timeLimit, _timeLimit);
        assertEq(executed, false);
    }  

    /**
     * @notice confirmTransaction
    */

     function testRevertsIfSenderIsNotOwner() public {
        vm.startPrank(address(10));
        vm.expectRevert("Not owner");
        queque.confirmTransaction(0);
    }

    function testRevertsIfRequestDoesNotExist() public {
        vm.startPrank(address(1));
        vm.expectRevert("Invalid id");
        queque.confirmTransaction(1);
    }

    function testRevertsIfRequestHasAlreadyBeenApprovedByOwner() public createRequest{
        vm.startPrank(address(2));
        queque.confirmTransaction(0);
        vm.expectRevert("Already approved");
        queque.confirmTransaction(0);
    }

    function testRevertIfCrowdfundingHasAlreadyApproved() public  createRequest{
        vm.startPrank(address(1));
        queque.confirmTransaction(0);
        vm.startPrank(address(2));
        queque.confirmTransaction(0);
        vm.startPrank(address(3));
        vm.expectRevert("Transaction already executed");
        queque.confirmTransaction(0);
    }

    function testConfirmTransition() public createRequest{
        vm.startPrank(address(1));
        queque.confirmTransaction(0);
        vm.startPrank(address(2));
        queque.confirmTransaction(0);

        assertEq(queque.isApproved(0, address(1)), true);
        (,,,, bool executed) = queque.proyectsInQueque(0);
        assertEq(executed, true);
    }  
}