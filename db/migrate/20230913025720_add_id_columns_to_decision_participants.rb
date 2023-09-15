class AddIdColumnsToDecisionParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :decision_participants, :user_id, :uuid, index: true
    add_foreign_key :decision_participants, :users, column: :user_id

    add_column :decision_participants, :participant_uid, :string, null: false, default: "", index: true
    DecisionParticipant.update_all("participant_uid = name")
    add_index :decision_participants, [:decision_id, :participant_uid], unique: true
  end
end
