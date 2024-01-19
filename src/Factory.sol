// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./Proxy.sol";
import "./Crowdfunding.sol";
import "./Voting.sol";

contract Factory   {
    uint256 public constant FROM_GWEI_TO_WEI = 1e9;

    event fundingContractCreated (
        address indexed pair,
        address indexed owner,
        string name,
        string description,
        uint256 target,
        string categorie,
        uint256 timeLimit,
        string imageCid
    );

    address public immutable implementationCrowdfundingContract;
    address public immutable implementationVotingContract;

	constructor()  {
        implementationCrowdfundingContract = address(new CrowdFunding());
        implementationVotingContract = address(new Voting());
	}

    function createCrowdFunding(
        string calldata name,
        string calldata description,
        uint256  _target,
        string calldata categorie,
        uint256  timeLimit,
        string calldata imageCid
    ) external returns (address pair) { 
        require(_target > 0, "Insuficient target");

        uint256 target = _target * FROM_GWEI_TO_WEI;

        {   // scope to avoid stack too deep errors
            pair = address(new Proxy(implementationCrowdfundingContract));
            (bool success,) = pair.call(abi.encodeWithSignature("initialize(uint256,address,uint256,address)", target, msg.sender, timeLimit, implementationVotingContract));
            require(success, "Failed to initialize");
        }
            
            emit fundingContractCreated(
                pair,
                msg.sender,
                name,
                description,
                target,
                categorie,
                timeLimit,
                imageCid
            );
    }

}