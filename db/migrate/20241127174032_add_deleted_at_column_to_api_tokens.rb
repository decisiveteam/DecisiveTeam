class AddDeletedAtColumnToApiTokens < ActiveRecord::Migration[7.0]
  def change
    remove_column :api_tokens, :active, :boolean
    add_column :api_tokens, :deleted_at, :datetime
  end
end
