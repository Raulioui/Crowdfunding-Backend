// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Deployer} from "../Deployer.sol";

/// @title Crowdfunding
/// @notice Basic crowdfunding contract
/// @author rauloiui
contract CrowdFunding  {

    /**
     * @notice Events
    */

    /// @notice Emitted once the target of the crowdfunding is reached
    /// @param pair The address of the crowdfunidng
    /// @param amountCollected The total amount collected in the crowdfunding
    /// @param owner The owner of the crowdfunding
    event CrowdFundingCompleted(
        address indexed pair,
        uint256 amountCollected,
        address indexed owner
    );

    /// @notice Emitted every time a donation is made
    /// @param donator The address of the donator
    /// @param message The message of the donation
    /// @param amount The amount of the donation
    event Donation(
        address indexed donator,
        string message,
        uint256 amount
    );

    /// @notice Emitted when the owner of the crowdfunding withdraws the funds
    /// @param owner The owner of the crowdfunding
    /// @param amount The total amount of the crowdfunding collected
    /// @param pair The address of the crowdfunidng
    event WithdrawCompleted(
        address indexed owner,
        uint256 amount,
        address indexed pair
    );

    /// @notice Emitted when a user withdraws their funds
    /// @param donator The address of the withdrawer
    /// @param amount The amount withdrawed (including fees)
    event UserWithdraw(
        address indexed donator,
        uint256 amount
    );


    /**
     * @notice Storage
    */

   address public deployerAddress;

    /// @return The withdraw fee
    uint16 public constant WITHDRAW_FEE = 95;

    /// @return Amount collected in the crowdfunding
    uint256 public amountCollected;

    /// @return The status of the crowdfunding
    bool public isCompleted;

    /// @return The target amount of the crowdfunding
    uint256 public immutable target;

    /// @return The time limit of the crowdfunding
    uint256 public immutable timeLimit;

    /// @return The cid of the data stored in IPFS of the crowdfunding
    bytes32 public immutable cid;

    /// @return The owner of the crowdfunding
    address public immutable owner;

    /// @notice Checks the donations of users
    /// @dev user => donation amount
    mapping (address => uint256) public donations;

    /**
     * @notice Constructor
    */

    constructor() {
        (target, timeLimit, cid, owner, deployerAddress) = Deployer(msg.sender).parametersCrowdfunding();
        isCompleted = false;
        amountCollected = 0;
    }

    /**
     * @notice External functions
    */

    /// @notice Donates to the crowdfunding
    /// @param message The message of the donation
    function donate(string memory message) external payable {
        require(msg.sender != owner, "The owner can't donate");
        require(!isCompleted, "The crowdfunding is completed");
        require(msg.value > 0, "Insuficient amount");

        (uint256 amountRemaining) = getAmountRemaining();

        amountCollected += msg.value;

        if(msg.value >= amountRemaining) {
            isCompleted = true;
            emit CrowdFundingCompleted(address(this), amountCollected, owner);
        }

        donations[msg.sender] += msg.value;

        emit Donation(msg.sender, message, msg.value);
    }

    /// @notice User withdraws their funds
    /// @dev The user can only withdraw if the crowdfunding is not completed and the time limit has not been reached, implements a 5% withdraw fee
    function withdrawUser() external {
        require(!isCompleted, "The crowdfunding is completed");
        require(block.timestamp < timeLimit, "The crowdfunding is closed");

        uint256 amount = donations[msg.sender];
        require(amount > 0, "You don't have any funds");

        uint256 penaltyAmount = (amount * WITHDRAW_FEE) / 100;

        donations[msg.sender] = 0;
        amountCollected -= penaltyAmount;

        (bool success, ) = payable(msg.sender).call{value: penaltyAmount}("");
        require(success, "Failed withdrawing");

        emit UserWithdraw(msg.sender, penaltyAmount);
    }

    /// @notice Owner withdraws the funds of the crowdfunding
    /// @dev Can only be called if the crowdfunding is completed or if the target has been reached
    /// @dev The user can only withdraw if the crowdfunding is not completed and the time limit has not been reached, implements a 5% withdraw fee
    function withdrawOwner() external {
        require(msg.sender == owner, "You're not the owner");

        if(isCompleted) {
            _withdrawOwner(amountCollected);
            return;
        }

        require(block.timestamp >= timeLimit, "The crowdfunding isn't closed");

        _withdrawOwner(amountCollected);
    }

    /**
     * @notice Internal functions
    */

    /// @notice Withdraws the funds of the crowdfunding
    function _withdrawOwner(uint256 _amountCollected) internal {
        amountCollected = 0;
        isCompleted = true;

        (bool success, ) = (owner).call{value: _amountCollected}("");
        require(success, "Failed withdrawing");
            
        emit WithdrawCompleted(msg.sender, _amountCollected, address(this));
    }

    /// @notice Gets the amount remaining to reach the target
    function getAmountRemaining() internal view returns(uint256 amountRemaining) {
        amountRemaining = target - amountCollected;
    }

    function getTarget() external view returns(uint256) {
        return target;
    }

    function getOwner() external view returns(address) {
        return owner;
    }

}