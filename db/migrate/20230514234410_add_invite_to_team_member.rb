class AddInviteToTeamMember < ActiveRecord::Migration[7.0]
  def change
    add_column :team_members, :team_invite_id, :bigint, null: true, foreign_key: true
  end
end
