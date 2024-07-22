// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title An interface for a contract that is capable of deploying crowdfundings
/// @notice A contract that constructs a crowdfunding must implement this to pass arguments to the crowdfunding
/// @dev This is used to avoid having constructor arguments in the crowdfunding contract, which results in the init code hash
/// of the crowdfunding being constant allowing the CREATE2 address of the crowdfunding to be cheaply computed on-chain
interface IDeployer {
    /// @notice Get the parameters to be used in constructing the crowdfuning, set transiently during crowdfunding creation.
    /// @dev Called by the crowdfunding constructor to fetch the parameters of the crowdfunding
    function parametersCrowdfunding()
        external
        view
        returns (
            uint256 target,
            uint256 timeLimit,
            bytes32 crfCid,
            address owner,
            address deployerAddress
        );
}