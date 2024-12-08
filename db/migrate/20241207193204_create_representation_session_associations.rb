class CreateRepresentationSessionAssociations < ActiveRecord::Migration[7.0]
  def change
    # This is a join table that represents the relationship between a representation session and a resource.
    # The association can cross studios, so we need to store the studio of the resource as well.
    # There should always be a corresponding semantic event in the activity log of the representation session.
    create_table :representation_session_associations, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :studio, null: false, foreign_key: true, type: :uuid
      # The index names are too long, so we need to specify a shorter name
      t.references :representation_session, null: false, foreign_key: true, type: :uuid, index: { name: 'index_rep_session_assoc_on_rep_session_id' }
      t.references :resource, null: false, polymorphic: true, type: :uuid, index: { name: 'index_rep_session_assoc_on_resource' }
      t.references :resource_studio, null: false, foreign_key: { to_table: :studios }, type: :uuid, index: { name: 'index_rep_session_assoc_on_resource_studio' }

      t.timestamps
    end
    add_index :representation_session_associations, [:representation_session_id, :resource_id, :resource_type], unique: true, name: 'index_rep_session_assoc_on_rep_session_and_resource'
  end
end
