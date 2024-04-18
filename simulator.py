from voter import Voter
import random 
import matplotlib.pyplot as plt

def generate_voters(n, q, p):
    voters = [] 
    initial_participation = 100
    for i in range(n):
        correct_votes = random.randint(0, 100) 
        if i < (1-q)*n:
            if i < p*(1-q)*n: 
                voter = Voter(is_honest=True, is_very_honest=True, voting_participations = initial_participation, correct_votes=correct_votes)
                voters.append(voter)
            else:
                voter = Voter(is_honest=True, is_very_honest=False, voting_participations = initial_participation, correct_votes=correct_votes)
                voters.append(voter)
        else:
            voter = Voter(is_honest=False, is_very_honest=False, voting_participations = initial_participation, correct_votes=correct_votes)
            voters.append(voter)
    return voters

def get_consensus(voters, news):
    votes = []  
    choices = [True, False]
    for voter in voters:
        # Choice indicated that whether the voter will vote correctly or not
        choice = False
        if voter.is_very_honest:
            # With probability 0.9 honest miner decides to voter correctly
            probabilities = [0.9, 0.1]
            choice = random.choices(choices, weights=probabilities, k=1)[0] 
        else:
            if voter.is_honest:
                # With probability 0.7 honest miner decides to voter correctly
                probabilities = [0.7, 0.3]
                choice = random.choices(choices, weights=probabilities, k=1)[0]
        if choice:
            votes.append(news)
        else :
            votes.append(not news)
    return votes

def update_trustworthiness(voters, consensus_result, votes): 
    for i in range(len(voters)):
        voters[i].voting_participations += 1
        if consensus_result == votes[i]:
            voters[i].correct_votes += 1 
        voters[i].update_trust_worthiness()
    return

def show_histogram(all_trusworthiness):
    # Plot the histogram of trustworthyness of all voters
    plt.hist(all_trusworthiness, bins=50, color='skyblue', edgecolor='black')

    # Add labels and title
    plt.title('Trustworthiness (0-1)')
    plt.xlabel('Values')
    plt.ylabel('Frequency')

    # Display grid
    plt.grid(True)

    # Show plot
    plt.show()

def run_simulator(N, q, p, steps): 
    # Generate all the voter to particiapte in consensus 
    threshold = 0.5
    voters = generate_voters(N, q, p) 
    for i in range(steps):
        # Randomly select news article to be true of false 
        news = random.choice([True, False])
        votes = get_consensus(voters, news)
        votes_sum = 0
        for j in range(len(voters)):
            if votes[j]:
                votes_sum += voters[j].trustworthiness
            else:
                votes_sum += (1-voters[j].trustworthiness)
        votes_sum /= len(voters)
        consensus_result =  votes_sum > threshold
        update_trustworthiness(voters, consensus_result, votes)
    all_trusworthiness = []
    for voter in voters:
        all_trusworthiness.append(voter.trustworthiness)   
    show_histogram(all_trusworthiness)
