pragma solidity ^0.8.0;

contract FakeNewsDApp {
    struct Voter {
        uint256 overallTrustworthiness;
        mapping(string => uint256) domainTrustworthiness;
        bool registered;
        uint256 balance;
    }

    struct Article {
        string content;
        string category;
        address uploader;
        bool classifiedAs;
        bool consensusReached;
        uint256 verificationFee;
        uint256 totalDeposits;
        mapping(address => bool) voters;

    }

    mapping(address => Voter) public voters;
    mapping(string => bool) public categories;
    mapping(string => Article) public articles;


    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register() external {
        require(!voters[msg.sender].registered, "User is already registered");
        voters[msg.sender].registered = true;
    }

    function submitArticle(string memory _content, string memory _category, uint256 _verificationFee) external {
        require(voters[msg.sender].registered, "User is not registered");
        require(categories[_category], "Invalid category");
        articles[_content] = Article(_content, _category, msg.sender, false, false, _verificationFee, 0, 0, 0);
    }

    function vote(string memory _content, bool _isReal) external {
        require(voters[msg.sender].registered, "User is not registered");
        require(articles[_content].uploader != address(0), "Article does not exist");
        require(!articles[_content].voters[msg.sender], "User has already voted");
        articles[_content].voters[msg.sender] = true;
    }

    function reevaluateTrustworthiness(string memory _content) {
        Article storage article = articles[_content];
        require(article.uploader != address(0), "Article does not exist");
        require(article.consensusReached, "Consensus not reached for this article yet");

        // Loop through all the voters who voted on the article
        for each voterAddress in article.voters {
            Voter storage voter = voters[voterAddress];

            // Check if the voter's vote matches with the consensus result
            bool voteMatchesConsensus = (article.voters[voterAddress] && article.classifiedAs) || (!article.voters[voterAddress] && !article.classifiedAs);

            // Adjust domainTrustworthiness based on the match with consensus
            if (voteMatchesConsensus) {
                // Increase domainTrustworthiness
                //trustFactor is calculated as correctlyVoted/totalVotes  of  voter
                voter.domainTrustworthiness[article.category] += trustFactor;
            } else {
                // Decrease domainTrustworthiness
                if (voter.domainTrustworthiness[article.category] >= trustFactor) {
                    voter.domainTrustworthiness[article.category] -= trustFactor;
                } else {
                // Ensure domainTrustworthiness does not go below zero
                voter.domainTrustworthiness[article.category] = 0;
                }
            }

            // Recalculate overallTrustworthiness for the voter
            // OverallTrustworthiness could be calculated as the average of domainTrustworthiness ratings
            voter.overallTrustworthiness = calculateOverallTrustworthiness(voter);
        }
    }

    function initiateConsensus(string memory _content, uint256 _threshold) external onlyOwner {
        Article storage article = articles[_content];
        require(article.uploader != address(0), "Article does not exist");
        require(!article.consensusReached, "Consensus already reached for this article");

        uint256 weightedSum = 0;
        uint256 totalWeight = 0;

        // Loop through all the voters who voted on the article
        for each voterAddress in article.voters {
            Voter storage voter = voters[voterAddress];
            uint256 voterWeight;

            //Calculate the weight of the voter based on their domainTrustworthiness
            if (article.voters[voterAddress]) {
                voterWeight = voter.domainTrustworthiness[article.category];
            } else {
                voterWeight = 1 - voter.domainTrustworthiness[article.category];
            }

            // Update the weighted sum 
            weightedSum += voterWeight;
        }

        // Calculate the consensus based on the weighted sum and threshold
        article.classifiedAs = (weightedSum >= _threshold)1:0;

        // Update the article's consensus status
        article.consensusReached = true;

        // Emit an event indicating the consensus result
        emit ConsensusReached(_content, isConsensusReal);
    }


    
    function distributeRewards(string memory _content) external onlyOwner{
        Article storage article = articles[_content];
        require(article.uploader != address(0), "Article does not exist");
        require(article.consensusReached, "Consensus not reached for this article yet");

        // Count the number of voters who voted correctly
        uint256 correctlyVotedVoters = 0;
        for each voterAddress in article.voters {
            if ((article.voters[voterAddress] && article.classifiedAs) || (!article.voters[voterAddress] && !article.classifiedAs)) {
                correctlyVotedVoters++;
            }
        }

        // Ensure there are voters who voted correctly
        require(correctlyVotedVoters > 0, "No voters voted correctly");

        // Calculate the reward per correctly voted voter
        uint256 rewardPerVoter = article.totalDeposits / correctlyVotedVoters;

        // Distribute rewards to correctly voted voters
        for each voterAddress in article.voters {
            if ((article.voters[voterAddress] && article.classifiedAs) || (!article.voters[voterAddress] && !article.classifiedAs)) {
            // Transfer the reward to the voter
            // NOTE: You need to implement a transfer function to send rewards to voters
            transferReward(voterAddress, rewardPerVoter);
        }
        }
    }

    function transferReward(address _recipient, uint256 _amount) {
        // Add the reward amount to the recipient's balance
        voters[_recipient].balance += _amount;
    }

    function bootstrapTrustworthiness() {
        // Define an array of known news articles for each category
        knownArticles = {
            "Politics": ["Article 1", "Article 2", "Article 3", "Article 4", "Article 5"],
            "Technology": ["Article 1", "Article 2", "Article 3", "Article 4", "Article 5"],
            // Add more categories as needed
        }

        // Loop through each category
        for each category in knownArticles {
            // Loop through each known article in the category
            for each article in knownArticles[category] {
                // Prompt users to vote on the article's authenticity
                promptUserToVote(article);
            }
        }

        // Calculate initial domainTrustworthiness for each user
        for each user in voters {
            for each category in categories {
                // Calculate agreement(%) with known truth for this category
                //calculateAgreement=(correctlyVotedinDomain/totalVotesInThatDomain)
                agreement = calculateAgreement(user, category);

                // Assign domainTrustworthiness based on agreement
                user.domainTrustworthiness[category] = agreement;
            
            }

        // Calculate overallTrustworthiness based on domainTrustworthiness ratings
            // OverallTrustworthiness could be calculated as the average of domainTrustworthiness ratings
            user.overallTrustworthiness = calculateOverallTrustworthiness(user);
        }
    }

    function addCategory(string memory _category) external onlyOwner {
        categories[_category] = true;
    }
}
