class TwitterOmniAuth < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :uid, :string
    add_column :users, :auth_provider, :string
    add_index :users, [:uid, :auth_provider], unique: true
  end
end
