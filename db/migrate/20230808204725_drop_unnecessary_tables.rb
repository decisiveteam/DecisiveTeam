class DropUnnecessaryTables < ActiveRecord::Migration[7.0]
  def up
    remove_column :decisions, :team_id
    remove_column :decisions, :created_by_id
    remove_column :options, :team_id
    remove_column :approvals, :team_id
    remove_column :decision_participants, :invite_id
    drop_table :webhooks
    drop_table :oauth_access_grants
    drop_table :oauth_access_tokens
    drop_table :oauth_applications
    drop_table :team_invites
    drop_table :team_members
    drop_table :decision_invites
    drop_table :teams
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
