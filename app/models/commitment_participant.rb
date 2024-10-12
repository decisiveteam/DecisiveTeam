class CommitmentParticipant < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :commitment
  belongs_to :user, optional: true
  # TODO
  # has_one :created_decision, class_name: 'Commitment', foreign_key: 'created_by_id'

  def authenticated?
    # If there is a user association, then we know the participant is authenticated
    user.present?
  end
end
