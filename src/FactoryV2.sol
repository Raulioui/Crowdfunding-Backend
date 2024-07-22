// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Deployer} from "./Deployer.sol";

/// @title FactoryV2
/// @notice Factory contract that creates grants
/// @author rauloiui
contract FactoryV2 is Deployer {

    /// @notice Emitted when a grant is created
    /// @param pair The address of the grant
    /// @param candidates The number of candidates
    /// @param cid The cid of the grant
    event GrantCreated(
        address pair,
        uint8 candidates,
        bytes32 cid
    );

    /// @notice The owner of the factory
    address public owner;

    /// @notice The maximum number of candidates allowed
    uint8 public constant MAX_CANDIDATES = 10;

    /// @notice Constructor
    constructor() {
        owner = msg.sender;
    }

    /// @notice Deploys a grants managers
    /// @param cid The cid of the grants stored in IPFS
    /// @param _candidates The number of maximun candidates in the grant
    /// @param _owners The owners of the  queque of the grant
    /// @param _confirmationsRequired The number of confirmations required to execute a proyect at the queque
    function deployGrant(bytes32 cid, uint8 _candidates, address[] memory _owners, uint8 _confirmationsRequired) external returns (address pair) {
        require(_confirmationsRequired > 0 && _confirmationsRequired <= _owners.length, "Invalid number of confirmations");
        require(_candidates > 1 && _candidates <= MAX_CANDIDATES, "Invalid number of candidates");
        require(msg.sender == owner, "Not owner");
        pair = deployGrant(_candidates, _owners,  _confirmationsRequired, msg.sender, cid);
        
        emit GrantCreated(pair, _candidates, cid);
    }  

}