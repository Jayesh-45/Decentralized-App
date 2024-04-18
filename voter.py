class Voter:
    def __init__(self, is_honest=False, is_very_honest=False, trustworthiness=0, voting_participations=0, correct_votes=0):
        self.is_honest = is_honest
        self.is_very_honest = is_very_honest 
        self.voting_participations = voting_participations
        self.correct_votes = correct_votes
        self.update_trust_worthiness()

    def __str__(self):
        return f"Voter: Honest={self.is_honest}, Very Honest={self.is_very_honest}, Trustworthiness={self.trustworthiness}, Voting Participations={self.voting_participations}, Correct Votes={self.correct_votes}"
    
    def update_trust_worthiness(self):
        self.trustworthiness = self.correct_votes/self.voting_participations