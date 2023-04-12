class RemoveContextAndTitleFromDecisions < ActiveRecord::Migration[7.0]
  def change
    remove_column :decisions, :context, :string
    remove_column :decisions, :title, :string
  end
end
