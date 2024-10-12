class CreateDecisionParticipants < ActiveRecord::Migration[7.0]
  def change
    create_table :decision_participants do |t|
      t.references :decision, null: false, foreign_key: true
      t.references :entity, polymorphic: true, null: true
      t.string :name
      t.references :invite, null: true, foreign_key: { to_table: :decision_invites }

      t.timestamps
    end
  end
end
