// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {GrantQueque} from "./GrantQueque.sol";
import {Deployer} from "../Deployer.sol";

/// @title Grant
/// @notice Grant contract that manages the quadratic funding of a pool of proyects
/// @author rauloiui
contract Grant {

    /**
     * @notice Events
    */

    /// @notice Emitted once a proyect is requested
    /// @param proyectOwner The owner of the proyect
    /// @param cid The cid of the data stored in IPFS
    event ProyectRequested(address proyectOwner, bytes32 cid);

    /// @notice Emitted once a proyect is accepted by the QFQueque
    /// @param proyectId The id of the proyect
    /// @param proyectOwner The owner of the proyect
    /// @param cid The cid of the data stored in IPFS
    event ProyectAccepted(uint256 proyectId, address proyectOwner, bytes32 cid);

    /// @notice Emitted once a donation is completed
    /// @param donator The address of the donator
    /// @param proyectId The id of the proyect
    /// @param amountDonated The amount donated in wei to the proyect
    /// @param numOfContributions The number of contributions to the proyect
    event DonationCompleted(address donator, uint256 proyectId, uint256 amountDonated, uint256 numOfContributions);

    /// @notice Emitted once a distribution of a proyect have been completed
    /// @param proyectOwner The owner of the proyect
    /// @param amount The amount distributed to the proyect
    /// @param proyectId The id of the proyect
    event FundsDistributed(address proyectOwner, uint256 amount, uint256 proyectId);

    /// @notice Emitted once the distribution of the pool have been completed
    /// @param totalAmountDistributed The total amount distributed to the proyects
    /// @param pool The address of this pool
    event PoolDistributionCompleted(uint256 totalAmountDistributed, address pool);

    /// @notice Emitted once the pool receives funds
    /// @param amount The amount received
    event FundsDeposited(uint256 amount);

    /**
     * @notice Storage
    */

    /// @notice The time that it lasts the request period of proyects
    uint256 public constant REQUEST_PERIOD = 21 days;

    /// @notice The time that it lasts the donation period of proyects
    uint256 public constant ACTIVE_PERIOD = 21 days;

    /// @notice The time that the request period ends
    uint256 public requestPeriodEnding;

    /// @notice The time that the donation period ends
    uint256 public fundingPeriod;

    /// @notice The cost for request a proyect to the queque
    uint256 public constant REQUEST_PRICE = 1e16; // 0.01 ether

    /// @notice The address of the queque of this pool
    GrantQueque public queque;

    /// @notice The maximun number of candidates that accepts this pool
    uint8 public immutable candidates;

    /// @notice The owner of the pool (Factory contract)
    address public managerAddress;
    
    /// @notice The cid of the data stored in IPFS of the grant
    bytes32 public cid;

    /// @notice The status of the pool
    enum FundingStatus {
        REQUESTS,
        ACTIVE,
        FINISHED
    }

    FundingStatus public fundingStatus;

    /// @notice The proyect data
    struct Proyect {
        address proyectOwner;
        uint256 numOfContributions;
        uint256 squaredRootedAmount;
        uint256 amountDonated;
        uint256 proyectId;
        uint256 donationPower;
    }

    Proyect[] public proyects;

    /// @notice Checks if a user has donated to a specific proyect
    /// @dev user => proyectId => hasDonated
    mapping(address => mapping(uint8 => bool)) public userHasDonated;

    /**
     * @notice Modifiers
    */

    /// @notice Modifier to check if the pool is in the request period
    /// @dev Reverts if the pool is not in the request period
    modifier onlyRequest() {
        require(fundingStatus == FundingStatus.REQUESTS, "Funding is not active");
        _;
    }

    /// @notice Modifier to check if the pool is in the funding period
    /// @dev Reverts if the pool is not in the funding period
    modifier onlyActive() {
        require(fundingStatus == FundingStatus.ACTIVE, "Funding is not active");
        _;
    }

    /// @notice Modifier to check if the pool has ended
    /// @dev Reverts if the pool has not ended
    modifier onlyFinished() {
        require(fundingStatus == FundingStatus.FINISHED, "Funding is not finished");
        _;
    }

    /// @notice Modifier to check if a proyects exists
    /// @dev Reverts if the proyect does not exist
    modifier proyectExists(uint256 _proyectId) {
        require(_proyectId < proyects.length, "Proyect does not exist");
        _;   
    }

    /// @notice Modifier to check if a user has donated to a proyect
    /// @dev Reverts if the user has already donated to the proyect
    modifier hasDonated(uint8 _proyectId) {
        require(!userHasDonated[msg.sender][_proyectId], "You already donated to this proyect");
        _;
    }   

    /// @notice Modifier to check if the caller is the owner
    /// @dev Reverts if caller is not the owner
    modifier onlyOwner() {
        require(msg.sender == managerAddress, "Only owner can call this function");
        _;
    } 

    /// @notice Modifier to check if the amount is greater than 0
    /// @dev Reverts if amount is not greater than 0
    modifier amountNotZero(uint256 _amount) {
        require(_amount > 0, "Amount must be greater than 0");
        _;
    }

    /**
     * @notice Constructor
    */

    /// @notice Constructor
    constructor(uint8 _candidates, address[] memory _owners, uint8 _confirmationsRequired, address _managerAddress, bytes32 _cid) {  
        candidates = _candidates;
        managerAddress = _managerAddress;
        requestPeriodEnding = block.timestamp + REQUEST_PERIOD;
        fundingStatus = FundingStatus.REQUESTS;
        cid = _cid;
        queque = new GrantQueque(_owners, _confirmationsRequired);
    }

    /**
     * @notice External functions
    */

    /// @notice Send a proyect request to the queque
    /// @dev Sending a proyect to the queque should have a cost for avoid innecesary requests
    /// @param _cid The data stored in IPFS of the proyect
    function sendProyectRequest(bytes32 _cid) external onlyRequest payable {
        require(msg.value >= REQUEST_PRICE, "Not enough funds");
        require(_cid[0] != 0, "Invalid cid");
        queque.createRequest(msg.sender, _cid);
        
        emit ProyectRequested(msg.sender, _cid);
    }

    /// @notice Receives an accepted proyect from the queque
    /// @param _owner The owner of the proyect
    /// @param _cid The data stored in IPFS of the proyect
    function receiveApprovedProyect(address _owner, bytes32 _cid) external onlyRequest {
        require(proyects.length < candidates, "Max number of candidates reached");
        require(msg.sender == address(queque), "Not allowed");
       
        proyects.push(Proyect({
            proyectOwner: _owner,
            numOfContributions: 0,
            squaredRootedAmount: 0,
            amountDonated: 0,
            proyectId: proyects.length,
            donationPower: 0
        }));
        // CHECK THE ID
        emit ProyectAccepted(proyects.length - 1, _owner, _cid);
    }

    /// @notice Donates to a proyect
    /// @param _proyectId The id of the proyect
    function donate(uint8 _proyectId) external payable onlyActive proyectExists(_proyectId) hasDonated(_proyectId) amountNotZero(msg.value){
        Proyect storage proyect = proyects[_proyectId];
        require(msg.sender != proyect.proyectOwner, "You can't donate to your own proyect");

        userHasDonated[msg.sender][_proyectId] = true;
     
        proyect.numOfContributions++;
        proyect.squaredRootedAmount += _sqrt(msg.value);
        proyect.amountDonated += msg.value;

        emit DonationCompleted(msg.sender, _proyectId, proyect.amountDonated, proyect.numOfContributions);
    }

    /// @notice Distrubute the funds to the proyects based on the quadratic funding formula
    /// @dev Gets the sum of the voting power of every proyects for calculate the respective amount to distribute
    /// @dev https://finematics.com/quadratic-funding-explained/
    function distributeFunds() external onlyActive onlyOwner {
        require(block.timestamp >= fundingPeriod, "Funding period has not ended");
        fundingStatus = FundingStatus.FINISHED;
        uint256 totalVotingPower = getTotalVotingPower();
        uint256 poolAmount = getPoolAmount();

        for(uint i = 0; i < proyects.length; i++) {
            Proyect storage proyect = proyects[i];
            uint256 amount = (((proyect.donationPower * 100) / totalVotingPower) * poolAmount) / 100;
          
            (bool success, ) = proyect.proyectOwner.call{value: amount}("");
            require(success, "Failed sending funds");

            emit FundsDistributed(proyect.proyectOwner, amount, proyect.proyectId);
        }

        fundingStatus = FundingStatus.FINISHED;
        emit PoolDistributionCompleted(poolAmount, address(this));
    }

    /// @notice Ends the period for request proyects
    function endRequestPeriod() external onlyRequest onlyOwner {
        require(block.timestamp >= requestPeriodEnding, "Request period has not ended");
        require(proyects.length == candidates, "Not enough candidates");
        fundingStatus = FundingStatus.ACTIVE;
        fundingPeriod = block.timestamp + ACTIVE_PERIOD;
    }

    /// @notice Allow everyone to contribute to the amount to distribute to the proyects in the pool
    function depositPoolFund() external payable onlyRequest amountNotZero(msg.value){
        emit FundsDeposited(msg.value);
    } 

    /**
     * @notice Internal functions
    */

    /// @notice Get the total voting power of the proyects in the pool
    /// @dev The voting power is the square of the square root of the donations in the proyect
    function getTotalVotingPower() internal returns(uint256){
        uint256 totalVotingPower;

        for(uint i = 0; i < proyects.length; i++) {
            Proyect storage proyect = proyects[i];
            uint256 votingPower = proyect.squaredRootedAmount * proyect.squaredRootedAmount;
            proyect.donationPower = votingPower;
            totalVotingPower += votingPower;
        }

        return totalVotingPower;
    }

    /// @notice Calculate the square root of a number (Babylonian method)
    /// @param x The number
    /// @return y The square root
    function _sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /// @notice Gets the pool amount to distribute
    function getPoolAmount() internal view returns(uint256){
        return address(this).balance;
    }
}