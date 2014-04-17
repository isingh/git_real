class CreateGithubProfiles < ActiveRecord::Migration
  def change
    create_table :github_profiles do |t|
      t.string :handle, null: false
      t.string :oauth_token, null: false
      t.string :name
      t.string :avatar_url
      t.timestamps
    end

    add_index(:github_profiles, :handle, unique: true)
  end
end
