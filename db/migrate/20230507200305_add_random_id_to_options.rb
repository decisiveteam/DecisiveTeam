class AddRandomIdToOptions < ActiveRecord::Migration[7.0]
  def up
    add_column :options, :random_id, :integer

    # Fill in existing rows with a random ID
    execute <<-SQL
      UPDATE options
      SET random_id = floor(random() * 1000000000)::integer
    SQL

    # Set the default value for new rows
    change_column_default :options, :random_id, 'floor(random() * 1000000000)::integer'
  end

  def down
    remove_column :options, :random_id
  end
end
