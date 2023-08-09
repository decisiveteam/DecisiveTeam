# This class is responsible for managing the business logic around
# creating decision participants and inviting users to participate.
class DecisionParticipantManager
  def initialize(decision:, entity: nil, name: nil)
    @decision = decision
    @entity = entity
    @name = name
    # TODO - add validations
  end

  def find_or_create_participant
    if @decision && @entity
      participant = DecisionParticipant.find_by(
        decision: @decision,
        entity: @entity,
        name: @name, # NOTE - this allows the same user to vote multiple times
      )
      if participant.nil?
        participant = DecisionParticipant.create!(
          decision: @decision,
          entity: @entity,
          name: @name,
        )
      end
    else
      # TODO - implement anonymous participants
      raise 'both decision and entity must be present to create a decision participant'
    end
    participant
  end
end