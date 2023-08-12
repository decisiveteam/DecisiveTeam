# This class is responsible for managing the business logic around
# creating decision participants and inviting users to participate.
class DecisionParticipantManager
  def initialize(decision:, name: nil)
    @decision = decision
    @name = name
    # TODO - add validations
  end

  def find_or_create_participant
    if @decision
      participant = DecisionParticipant.find_by(
        decision: @decision,
        name: @name,
      )
      if participant.nil?
        participant = DecisionParticipant.create!(
          decision: @decision,
          name: @name,
        )
      end
    else
      raise 'decision must be present to create a decision participant'
    end
    participant
  end
end