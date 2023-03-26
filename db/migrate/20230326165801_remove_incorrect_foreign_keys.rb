class RemoveIncorrectForeignKeys < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :approvals, column: :created_by_id
    remove_foreign_key :decisions, column: :created_by_id
    remove_foreign_key :options, column: :created_by_id
  end
end
