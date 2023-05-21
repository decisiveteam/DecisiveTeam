# This class is responsible for managing the business logic around
# creating decision participants and inviting users to participate.
class DecisionParticipantManager
  def initialize(decision:, entity: nil, invite: nil, name: nil)
    @decision = decision
    @entity = entity
    @invite = invite
    @name = name
    # TODO - add validations
  end

  def find_or_create_participant
    if @decision && @entity
      DecisionParticipant.find_or_create_by(
        decision: @decision,
        entity: @entity,
        name: @name || @entity.name,
        invite: @invite
      )
    else
      # TODO - implement anonymous participants
      raise 'both decision and entity must be present to create a decision participant'
    end
  end
end