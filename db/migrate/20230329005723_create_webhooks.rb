class CreateWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table :webhooks do |t|
      t.string :url
      t.string :secret
      t.string :event
      t.references :team, null: false, foreign_key: true
      t.references :decision_log, null: true, foreign_key: true
      t.references :decision, null: true, foreign_key: true
      t.references :created_by, user: true, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
