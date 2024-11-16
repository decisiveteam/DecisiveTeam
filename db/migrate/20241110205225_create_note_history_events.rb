class CreateNoteHistoryEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :note_history_events, id: :uuid do |t|
      t.references :note, null: false, type: :uuid, foreign_key: true
      t.references :user, null: true, type: :uuid, foreign_key: true
      t.string :event_type
      t.timestamp :happened_at

      t.timestamps
    end

  end
end
