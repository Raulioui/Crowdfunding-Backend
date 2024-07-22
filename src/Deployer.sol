// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IDeployer} from './interfaces/IDeployer.sol';
import {CrowdFunding} from './Crowdfunding/Crowdfunding.sol';
import {Grant} from "./Grant/Grant.sol";

/// @title Deployer
/// @notice Contract that deploys contracts
/// @author rauloiui
contract Deployer is IDeployer {

    /**
     * @notice Events
    */

    /// @notice Emitted once a proyect is requested
    /// @param owner The owner of the proyect
    /// @param pair The address of the proyect
    /// @param crfCid The cid of the proyect data stored in IPFS
    /// @param target The target amount of the proyect
    /// @param timeLimit The time limit of the proyect
    event CrowdfundingCreated(
        address owner,
        address pair,
        bytes32 crfCid,
        uint256 target,
        uint256 timeLimit
    );

    /**
     * @notice Storage
    */

    /// @notice Checks the crowdfundings created
    /// @dev owner => pair 
    mapping(address => address) public crowdfundings;

    /// @inheritdoc IDeployer
    ParametersCrowdfunding public override parametersCrowdfunding;

    /// @notive Parameters of the Crowdfunding
    struct ParametersCrowdfunding {
        uint256 target;
        uint256 timeLimit;
        bytes32 crfCid;
        address owner;
        address deployerAddress;
    }

    /// @notice Parameters of the Quadratic Funding manager
    struct ParametersGrant {
        uint8 candidates;
        address[] owners;
        uint8 confirmationsRequired;
        address managerAddress;
    }

    /**
     * @notice Functions
    */

    /// @dev Deploys a crowdfunding with the given parameters by transiently setting the parameters storage slot and then
    /// clearing it after deploying the pool.
    /// @param target The target amount of the crowdfunding
    /// @param timeLimit The time limit of the crowdfunding
    /// @param crfCid The cid of the crowdfunding data stored in IPFS
    /// @param _owner The owner of the crowdfunding
    function deployCrowdfundingProyect(
        uint256 target,
        uint256 timeLimit,
        bytes32 crfCid,
        address _owner
    ) internal returns (address pair) {
        parametersCrowdfunding = ParametersCrowdfunding({target: target, timeLimit: timeLimit, crfCid: crfCid, owner: _owner, deployerAddress: (address(this))});
        pair = address(new CrowdFunding{salt: keccak256(abi.encode(target, timeLimit, crfCid))}());
        crowdfundings[_owner] = pair;
        emit CrowdfundingCreated(_owner, pair, crfCid, target, timeLimit);
        delete parametersCrowdfunding;
    }

    /// @dev Deploys a grant with the given parameters by transiently setting the parameters storage slot and then
    /// clearing it after deploying the pool.
    /// @param _candidates The number of candidates
    /// @param _owners The owners of the queque of the grant
    /// @param _confirmationsRequired The number of confirmations required to execute a transaction in the queque
    /// @param _managerAddress The address of the manager of the grant
    function deployGrant(
        uint8 _candidates,
        address[] memory _owners,
        uint8 _confirmationsRequired,
        address _managerAddress,
        bytes32 _cid
    ) internal returns (address pair) {
        pair = address(new Grant{salt: keccak256(abi.encode(_candidates, _confirmationsRequired, _managerAddress))}(_candidates, _owners, _confirmationsRequired, _managerAddress, _cid));
    }

}