class AddDescriptionToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :description, :text
  end
end
