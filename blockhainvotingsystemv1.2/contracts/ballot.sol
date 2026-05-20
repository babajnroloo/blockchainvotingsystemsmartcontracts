// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Voting system with admin-controlled voter registration
/// @dev Only registered voters can vote. Owner registers voters.
contract VotingWithRegistration {
    // --- Data structures ---
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // --- State variables ---
    address public owner;
    Candidate[] public candidates;
    mapping(address => bool) public isRegistered;
    mapping(address => bool) public hasVoted;
    address[] public registeredVotersList;

    // --- Events ---
    event CandidateAdded(string name, uint256 index);
    event VoterRegistered(address indexed voter);
    event VoteCasted(address indexed voter, string candidateName, uint256 candidateIndex);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "You are not a registered voter");
        _;
    }

    /// @notice Constructor sets the contract owner and adds initial candidates.
    /// @param _candidateNames Array of candidate names (e.g., ["Vincent","Junior","Ruto"])
    constructor(string[] memory _candidateNames) {
        owner = msg.sender;
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            candidates.push(Candidate({ name: _candidateNames[i], voteCount: 0 }));
            emit CandidateAdded(_candidateNames[i], i);
        }
    }

    /// @notice Allows the owner to add a new candidate after deployment.
    /// @param _name Name of the new candidate.
    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate({ name: _name, voteCount: 0 }));
        emit CandidateAdded(_name, candidates.length - 1);
    }

    /// @notice Owner registers a voter by their Ethereum address.
    /// @param _voter The address to register.
    function registerVoter(address _voter) public onlyOwner {
        require(!isRegistered[_voter], "Voter already registered");
        isRegistered[_voter] = true;
        registeredVotersList.push(_voter);
        emit VoterRegistered(_voter);
    }

    /// @notice Owner can register multiple voters at once.
    /// @param _voters Array of addresses to register.
    function registerMultipleVoters(address[] memory _voters) public onlyOwner {
        for (uint256 i = 0; i < _voters.length; i++) {
            if (!isRegistered[_voters[i]]) {
                isRegistered[_voters[i]] = true;
                registeredVotersList.push(_voters[i]);
                emit VoterRegistered(_voters[i]);
            }
        }
    }

    /// @notice Cast a vote for a specific candidate. Only registered voters can vote.
    /// @param _candidateIndex The index of the candidate in the `candidates` array.
    function vote(uint256 _candidateIndex) public onlyRegistered {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate index");

        hasVoted[msg.sender] = true;
        candidates[_candidateIndex].voteCount++;

        emit VoteCasted(msg.sender, candidates[_candidateIndex].name, _candidateIndex);
    }

    /// @notice Returns the total number of candidates.
    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    /// @notice Returns candidate details by index.
    function getCandidate(uint256 _index) public view returns (string memory name, uint256 voteCount) {
        require(_index < candidates.length, "Index out of bounds");
        Candidate storage c = candidates[_index];
        return (c.name, c.voteCount);
    }

    /// @notice Returns the total number of registered voters.
    function getRegisteredVoterCount() public view returns (uint256) {
        return registeredVotersList.length;
    }

    /// @notice Returns a list of all registered voter addresses.
    function getAllRegisteredVoters() public view returns (address[] memory) {
        return registeredVotersList;
    }

    /// @notice Checks if a specific address is registered.
    function checkRegistration(address _voter) public view returns (bool) {
        return isRegistered[_voter];
    }

    /// @notice Returns the current winner (candidate with most votes).
    function getWinner() public view returns (string memory winnerName, uint256 winnerVotes) {
        require(candidates.length > 0, "No candidates");
        uint256 maxVotes = 0;
        uint256 winnerIndex = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }
        return (candidates[winnerIndex].name, candidates[winnerIndex].voteCount);
    }
}