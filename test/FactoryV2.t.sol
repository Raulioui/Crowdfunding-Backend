// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {FactoryV2} from "../src/FactoryV2.sol";
import {Queque} from "../src/Crowdfunding/Queque.sol";

contract FactoryV2Test is Test {
    FactoryV2 public factory;
    Queque public queque;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);

        queque = new Queque(owners, 2);
        
        factory = new FactoryV2();
    }

    /**
     * @notice deployGrant
    */

   function testRevertsNumberOfConfirmationsInvalid() public {
        vm.expectRevert("Invalid number of confirmations");
        factory.deployGrant("cid", 3, new address[](3), 0);
    }
    
    function testRevertsNumberOfCandidatesInvalid() public {
        vm.expectRevert("Invalid number of candidates");
        factory.deployGrant("cid", 11, new address[](3), 2);
    }

    function testRevertsIfDeployerIsNotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert("Not owner");
        factory.deployGrant("cid", 3, new address[](3), 2);
    }

    function testdeployGrant() public {
        address[] memory owners = new address[](3);
        owners[0] = address(1);
        owners[1] = address(2);
        owners[2] = address(3);
        address pair = factory.deployGrant( "cid", 3, owners, 2);
        assert(pair != address(0));
    }

}