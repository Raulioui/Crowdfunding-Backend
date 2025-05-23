// SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Deployer} from "../Deployer.sol";

/// @title Queque
/// @notice Queque for all the crowdfundings requested
/// @author rauloiui
contract Queque is Deployer {

    /**
     * @notice Events
    */

    /// @notice Emitted once a request is emmited
    /// @param id The id of the project
    /// @param cid The CID of the project
    /// @param target The target of the project
    /// @param timeLimit The time limit of the project
    event ProjectRequested(
        uint8 id,
        address owner,
        bytes32 cid,
        uint256 target,
        uint256 timeLimit
    );

    /// @notice Emitted once a project has been approved
    /// @param id The id of the project
    /// @param confirmationCount The amount of confirmations
    /// @param confirmationsRequired The amount of confirmations required of the queque
    event ProjectApproved(
        uint8 id,
        uint256 confirmationCount,
        uint256 confirmationsRequired
    );

    /// @notice Emitted once project has been executed
    /// @param id The id of the project
    /// @param pair The address of the crowdfunidng
    /// @param target The target of the project
    /// @param timeLimit The time limit of the project
    /// @param cid The CID of the project
    /// @param owner The owner of the project
    event ProjectExecuted(
        uint8 id,
        address pair,
        uint256 target,
        uint256 timeLimit,
        bytes32 cid,
        address owner
    );

    /**
     * @notice Storage
    */

    /// @notice Conversion from Gwei to Wei
   uint256 public constant FROM_GWEI_TO_WEI = 1e9;

    /// @notice Amount to request a project
   uint256 public constant REQUEST_PRICE = 1e16; // 0.01 ether

    /// @notice Minimum time limit that a project can have
    uint256 public MIN_TIME_LIMIT = 5 days;

    /// @notice Maximum of owners that a project can have
    uint constant public MAX_OWNER_COUNT = 5;

    /// @notice All the projects that have been executed
    address[] public projectsExecuted;

    /// @notice Owners of the queque
    address[] public owners;

    /// @notice Number of confirmations required to execute a project
    uint public confirmationsRequired;

    /// @notice Checks if a user has is owner
    /// @dev user => isOwner
    mapping(address => bool) public isOwner;

    /// @notice Checks if a user has approved a project
    /// @dev projectId => owner => isApproved
    mapping(uint => mapping(address => bool)) public isApproved;

    /// @notice Project data
    struct Project {
        bytes32 cid;
        uint256 target;
        address owner;
        uint256 timeLimit;
        bool executed;
    }

    Project[] public projectsInQueque;

    /**
     * @notice Modifiers
    */

    /// @notice Modifier to check if a user is owner
    /// @dev Reverts if the user is not owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    /// @notice Modifier to check if projects exists
    /// @dev Reverts if the project does not exist
    modifier projectExist(uint _id) {
        require(_id < projectsInQueque.length, "Invalid id");
        _;
    }

    /// @notice Modifier to check if a owner already approved a project
    /// @dev Reverts if the owner already approved the project
    modifier projectNotApprovedByOwner(uint _id) {
        require(!isApproved[_id][msg.sender], "Already approved");
        _;
    }

    /// @notice Modifier to check if a projects already executed
    /// @dev Reverts if the project  already executed
    modifier projectNotExecuted(uint _id) {
        require(!projectsInQueque[_id].executed, "Transaction already executed");
        _;
    }

    /**
     * @notice Constructor
    */

    constructor(address[] memory _owners, uint _confirmationsRequired) {
        require(_owners.length > 1 && _owners.length <= MAX_OWNER_COUNT, "Invalid number of owners");
        require(_confirmationsRequired > 0 && _confirmationsRequired <= _owners.length, "Invalid number of confirmations");

        for(uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid address provided");
            require(!isOwner[_owners[i]], "Duplicate owner");
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
        
        confirmationsRequired = _confirmationsRequired;
    }

    /**
     * @notice External functions
    */

    /// @notice Creates a new request for a project
    /// @param _qfCid The CID of the crowdffunding data stored in IPFS
    /// @param _target The target amount of the project
    /// @param _timeLimit The time limit of the project
    function createRequest(
        bytes32 _qfCid,
        uint256 _target,
        uint256 _timeLimit
    ) external payable {
        require(_qfCid[0] != 0, "Invalid cid");
        require(_target > 0, "Insuficient target");
        require(_timeLimit > block.timestamp + MIN_TIME_LIMIT, "Invalid time limit");
        require(msg.value >= REQUEST_PRICE, "Insuficient amount");

        uint256 target = _target * FROM_GWEI_TO_WEI;

        projectsInQueque.push(Project({
            cid: _qfCid,
            owner: msg.sender,
            target: target,
            timeLimit: _timeLimit,
            executed: false
        }));

        emit ProjectRequested(uint8(projectsInQueque.length - 1), msg.sender, _qfCid, target, _timeLimit);
    }

    /// @notice Confirms the crowdfunding request
    /// @param _id The id of the crowdfunding request
    function confirmTransaction(uint _id) 
        external 
        onlyOwner
        projectExist(_id) 
        projectNotApprovedByOwner(_id)
        projectNotExecuted(_id)
    {
        isApproved[_id][msg.sender] = true;

        uint256 confirmationCount = getConfirmationCount(_id);
        
        emit ProjectApproved(uint8(_id), confirmationCount, confirmationsRequired);

        if(confirmationCount >= confirmationsRequired) {
            Project storage crf = projectsInQueque[_id];
            crf.executed = true;
      
            address pair = deployCrowdfundingProject(crf.target, crf.timeLimit, crf.cid, crf.owner);

            projectsExecuted.push(pair);
            
            emit ProjectExecuted(uint8(_id), pair, crf.target, crf.timeLimit, crf.cid, crf.owner);
        }
    }

    /**
     * @notice Internal functions
    */

    /// @notice Returns the amount of confirmations of a project
    /// @param id The id of the crowdfunding request
    function getConfirmationCount(uint id) internal view returns(uint256) {
        uint confirmationCount;

        for(uint i; i < owners.length; i++) {
            if(isApproved[id][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount;
    }

}