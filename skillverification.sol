// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SkillVerse
 * @dev A decentralized platform for skill verification and freelance job matching.
 */
contract Project {

    // Represents a freelancer on the platform
    struct Freelancer {
        bool isRegistered;
        address walletAddress;
        // Mapping from a skill (e.g., "Solidity") to its verification status
        mapping(string => bool) verifiedSkills;
        // To track who verified which skill
        mapping(string => mapping(address => bool)) verifiers;
    }

    // Represents a job posted by a client
    struct Job {
        uint256 id;
        address client;
        string description;
        uint256 budget;
        bool isOpen;
        address hiredFreelancer;
    }

    // Mapping from an address to a Freelancer struct
    mapping(address => Freelancer) public freelancers;
    // Mapping from a job ID to a Job struct
    mapping(uint256 => Job) public jobs;

    uint256 public jobCounter;

    // Events to notify off-chain applications
    event FreelancerRegistered(address indexed freelancerAddress);
    event SkillVerified(address indexed freelancerAddress, string skill, address indexed verifier);
    event JobPosted(uint256 indexed jobId, address indexed client, uint256 budget);

    /**
     * @dev Registers the caller as a freelancer.
     * The function is a core requirement for participating in the ecosystem.
     */
    function registerFreelancer() public {
        require(!freelancers[msg.sender].isRegistered, "You are already registered as a freelancer.");
        
        freelancers[msg.sender].isRegistered = true;
        freelancers[msg.sender].walletAddress = msg.sender;
        
        emit FreelancerRegistered(msg.sender);
    }

    /**
     * @dev Allows a registered freelancer to verify a skill for another freelancer.
     * This creates a decentralized web of trust. A freelancer cannot verify their own skill.
     * @param _freelancer The address of the freelancer whose skill is being verified.
     * @param _skill A string representing the skill, e.g., "JavaScript".
     */
    function verifySkill(address _freelancer, string memory _skill) public {
        require(freelancers[msg.sender].isRegistered, "Only registered freelancers can verify skills.");
        require(freelancers[_freelancer].isRegistered, "The specified address is not a registered freelancer.");
        require(msg.sender != _freelancer, "You cannot verify your own skills.");
        require(!freelancers[_freelancer].verifiers[_skill][msg.sender], "You have already verified this skill for this freelancer.");

        freelancers[_freelancer].verifiedSkills[_skill] = true;
        freelancers[_freelancer].verifiers[_skill][msg.sender] = true;

        emit SkillVerified(_freelancer, _skill, msg.sender);
    }

    /**
     * @dev Allows any address to post a job to the marketplace.
     * @param _description A detailed description of the job requirements.
     * @param _budget The payment offered for the job, in wei.
     */
    function postJob(string memory _description, uint256 _budget) public payable {
        require(msg.value == _budget, "The sent Ether must match the job budget for escrow.");
        
        jobCounter++;
        uint256 newJobId = jobCounter;

        jobs[newJobId] = Job({
            id: newJobId,
            client: msg.sender,
            description: _description,
            budget: _budget,
            isOpen: true,
            hiredFreelancer: address(0)
        });

        emit JobPosted(newJobId, msg.sender, _budget);
    }
}
