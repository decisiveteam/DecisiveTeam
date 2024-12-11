class AddDeadlineToNotes < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :deadline, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
