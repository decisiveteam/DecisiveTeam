class CreateCommitmentParticipants < ActiveRecord::Migration[7.0]
  def change
    create_table :commitment_participants, id: :uuid do |t|
      t.references :commitment, null: false, type: :uuid, foreign_key: true
      t.references :user, null: true, type: :uuid, foreign_key: true
      t.string :participant_uid, null: false, default: "", index: true
      t.string :name
      t.boolean :committed, null: false, default: false

      t.timestamps
    end
    add_index :commitment_participants, [:commitment_id, :participant_uid], unique: true, name: 'index_commitment_participants_on_commitment_and_uid'
  end
end
