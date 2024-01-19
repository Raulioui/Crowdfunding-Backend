// SPDX-License-Identifier: MIT

import "./Voting.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./Proxy.sol";

pragma solidity 0.8.20;
 
// IMPLEMENTAR TOKENS RECOMENSA
contract CrowdFunding is Initializable  {
    uint16 public constant WITHDRAW_FEE = 95;

    address public contractOwner;
    uint256 public target;
    uint256 public amountCollected;
    bool public isCompleted;
    uint256 public closingDate;

    mapping (address => uint256) public donations;
    mapping (address => uint256) public percentage;

    address public implementationContract;

    address[] public votingContracts;
    mapping (address => uint256) public votingTarget;
    mapping (address => mapping(address => bool)) public hasVoted;

    event CrowdFundingCompleted(
        address indexed pair,
        uint256 amountCollected,
        address indexed contractOwner
    );

    event Donation(
        address indexed donator,
        string message,
        uint256 amount
    );

    event WithdrawCompleted(
        address indexed contractOwner,
        uint256 amount,
        address indexed pair
    );

    event UserWithdraw(
        address indexed donator,
        uint256 amount,
        uint256 amountCollected
    );

    event VotingCreated(
        address indexed pair,
        string message,
        address votingContract
    );

    function initialize(
        uint256 _target,
        address _contractOwner,
        uint256 _closingData,
        address _implementationContract
    ) initializer external {
        amountCollected = 0;
        target = _target;
        contractOwner = _contractOwner;
        isCompleted = false;
        closingDate = _closingData;
        implementationContract = _implementationContract;
    }

    function donate(string memory message) external payable {
        require(msg.sender != contractOwner, "The owner can't donate");
        require(!isCompleted, "The crowdfunding is completed");
        require(msg.value > 0, "Insuficient amount");

        (uint256 amountRemaining) = getAmountRemaining();

        amountCollected += msg.value;

        if(msg.value >= amountRemaining) {
            isCompleted = true;
            emit CrowdFundingCompleted(address(this), amountCollected, contractOwner);
        }

        donations[msg.sender] += msg.value;

        uint256 percent = calculatePercentage(donations[msg.sender], amountCollected);
        percentage[msg.sender] = percent;

        emit Donation(msg.sender, message, msg.value);
    }

    // consider inplement push/pull pattern
    function withdrawOwner() external {
        require(msg.sender == contractOwner, "You're not the owner");

        if(isCompleted) {
            _withdrawOwner(amountCollected);
            return;
        }

        require(block.timestamp >= closingDate, "The crowdfunding isn't closed");

        _withdrawOwner(amountCollected);
    }

    function withdrawUser() external {
        require(!isCompleted, "The crowdfunding is completed");
        require(block.timestamp < closingDate, "The crowdfunding is closed");

        uint256 amount = donations[msg.sender];
        require(amount > 0, "You don't have any funds");

        uint256 penaltyAmount = (amount * WITHDRAW_FEE) / 100;

        donations[msg.sender] = 0;
        percentage[msg.sender] = 0;
        amountCollected -= penaltyAmount;

        (bool success, ) = payable(msg.sender).call{value: penaltyAmount}("");
        require(success, "Failed withdrawing");

        emit UserWithdraw(msg.sender, penaltyAmount, amountCollected);
    }

    function createVoting(string memory message) external returns (address pair){
        require(msg.sender == contractOwner, "You are not the owner");
        require(!isCompleted, "The crowdfunding is completed");
        require(votingContracts.length < 6, "You can't create more votings");

        pair = address(new Proxy(implementationContract));
        (bool success, ) = pair.call(abi.encodeWithSignature("initialize(address,address)", contractOwner, address(this)));
        require(success, "Failed to initialize");
        votingContracts.push(pair);
        votingTarget[pair] = block.timestamp + 1 days;
        emit VotingCreated(address(this), message, pair);
    } 

    function _withdrawOwner(uint256 _amountCollected) internal {
        amountCollected = 0;
        isCompleted = true;

        (bool success, ) = (msg.sender).call{value: _amountCollected}("");
        require(success, "Failed withdrawing");
            
        emit WithdrawCompleted(msg.sender, _amountCollected, address(this));
    }

    function vote(uint8 userVote, address votingPair) external {
        require(votingTarget[votingPair] != 0, "The voting doesn't exist");
        require(donations[msg.sender] > 0, "You're not allowed to vote");
        require(msg.sender != contractOwner, "The owner is not allowed to vote");
        require(block.timestamp < votingTarget[votingPair], "The voting is close");
        require(userVote <= 1, "Invalid vote");
        bool isVoted = hasVoted[msg.sender][votingPair];
        require(!isVoted, "You already voted");

        hasVoted[msg.sender][votingPair] = true;

        Voting(votingPair).vote(userVote, percentage[msg.sender]);
    }

    function getAmountRemaining() internal view returns(uint256 amountRemaining) {
        amountRemaining = target - amountCollected;
    }

    function calculatePercentage(uint256 amount, uint256 totalAmount) internal pure returns(uint256 percent){
        percent = (amount * 100) / totalAmount;
    }

}