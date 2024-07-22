// SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Grant} from "./Grant.sol";

/// @title GrantQueque
/// @notice Queque for a grant, it belongs to a single grant
/// @author rauloiui
contract GrantQueque {

    /**
     * @notice Events
    */

    /// @notice Emitted once a request is emmited
    /// @param id The id of the proyect
    /// @param cid The CID of the proyect
    event ProyectRequested(uint8 id, bytes32 cid);

    /// @notice Emitted once a proyect has been approved
    /// @param id The id of the proyect
    event ProyectApproved(uint8 id);

    /// @notice Emitted once proyect has been executed
    /// @param id The id of the proyect
    event ProyectExecuted(uint8 id, address owner);

    /**
     * @notice Storage
    */

    /// @notice The address of the grant
    address public grantAddress;

    /// @notice The owners of the queque
    address[] public owners;

    /// @notice Confirmations required for execute a proyect
    uint public confirmationsRequired;

    /// @notice The proyect data
    struct Proyect {
        bytes32 cid;
        address owner;
        bool executed;
    }

    Proyect[] public proyectsInQueque;

    /// @notice Checks if a user is owner of the queque
    /// @dev user => isOwner
    mapping(address => bool) public isOwner;

    /// @notice Checks if user has approved a proyect
    /// @dev proyectId => owner => isApproved
    mapping(uint => mapping(address => bool)) public isApproved;

    /**
     * @notice Modifiers
    */

    /// @notice Modifier to check if a user is owner of the queque
    /// @dev Reverts if the user is not owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    /// @notice Modifier to check if a id is valid
    /// @dev Reverts if is does not belongs to a proyect
    modifier proyectExist(uint _id) {
        require(_id < proyectsInQueque.length, "Invalid id");
        _;
    }

    /// @notice Modifier to check if a owner already approved a proyect
    /// @dev Reverts if the owner already approved the proyect
    modifier proyectNotApprovedByOwner(uint _id) {
        require(!isApproved[_id][msg.sender], "Already approved");
        _;
    }

    /// @notice Modifier to check if the proyect already has been executed
    /// @dev Reverts if the proyect already has been executed
    modifier proyectNotExecuted(uint _id) {
        require(!proyectsInQueque[_id].executed, "Transaction already executed");
        _;
    }

    /**
     * @notice Constructor
    */

    /// @notice Constructor
    constructor(address[] memory _owners, uint _confirmationsRequired) {
        for(uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid address provided");
            require(!isOwner[_owners[i]], "Duplicate owner");
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
        
        grantAddress = msg.sender;
        confirmationsRequired = _confirmationsRequired;
    }

    /**
     * @notice External functions
    */
 
    /// @notice Receives a request from the grant
    /// @param sender The address of the proyect owner
    /// @param _grantCid The CID of the grant data stored in IPFS
    function createRequest(
        address sender,
        bytes32 _grantCid
    ) external {
        require(msg.sender == grantAddress, "Not allowed");

        proyectsInQueque.push(Proyect({
            cid: _grantCid,
            owner: sender,
            executed: false
        }));
        
        emit ProyectRequested(uint8(proyectsInQueque.length - 1), _grantCid);
    }

    /// @notice Confirms the crowdfunding request
    /// @param _id The id of the crowdfunding request
    function confirmTransaction(uint _id) 
        external 
        onlyOwner
        proyectExist(_id) 
        proyectNotApprovedByOwner(_id)
        proyectNotExecuted(_id)
    {
        isApproved[_id][msg.sender] = true;
        
        emit ProyectApproved(uint8(_id));

        if(getConfirmations(_id) >= confirmationsRequired) {
            Proyect storage crf = proyectsInQueque[_id];
            crf.executed = true;

            Grant(grantAddress).receiveApprovedProyect(crf.owner, crf.cid);
         
            emit ProyectExecuted(
                uint8(_id),
                crf.owner
            );
        }
    }

    /**
     * @notice Internal functions
    */

    /// @notice Checks if the crowdfundng request is approved
    /// @param id The id of the crowdfunding request
    function getConfirmations(uint id) internal view returns(uint256) {
        uint confirmationCount;

        for(uint i; i < owners.length; i++) {
            if(isApproved[id][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount ;
    }
}