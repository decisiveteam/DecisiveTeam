class AddAuthRequiredToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :auth_required, :boolean, default: false
  end
end
