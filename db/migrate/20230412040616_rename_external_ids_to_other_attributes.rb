class RenameExternalIdsToOtherAttributes < ActiveRecord::Migration[7.0]
  def change
    rename_column :team_members, :external_ids, :other_attributes
    rename_column :decisions, :external_ids, :other_attributes
    rename_column :options, :external_ids, :other_attributes
  end
end
