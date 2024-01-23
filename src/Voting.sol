//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";


contract Voting is Initializable {
    uint256 public votes;
    uint256 public yesVotes;
    uint256 public noVotes;
    uint256 public timeLimit;  
    address public owner;

    address public crowdfundingContract;

    event Voted(
        uint256 votes,
        uint256 yesVotes,
        uint256 noVotes
    );

    uint256 constant public VOTE_VALUE = 10**6;

    mapping(address => bool) public hasVoted;

    function initialize(
        address _owner,
        address _crowdfundingContract
    ) initializer  external {
        votes = 0;
        yesVotes = 0;
        noVotes = 0;
        owner = _owner;
        timeLimit = block.timestamp + 1 days;
        crowdfundingContract = _crowdfundingContract;
    }

    function vote(uint8 userVote, uint256 voterPercentage) external {
        require(msg.sender == crowdfundingContract, "You're not allowed to vote");
        votes++;
        
        if(userVote == 0) {
            noVotes += VOTE_VALUE * voterPercentage;
        }

        if(userVote == 1) {
            yesVotes += VOTE_VALUE * voterPercentage;
        }  

        emit Voted(votes, yesVotes, noVotes);
    }

}