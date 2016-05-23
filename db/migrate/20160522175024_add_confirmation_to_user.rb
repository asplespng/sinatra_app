class AddConfirmationToUser < ActiveRecord::Migration
  def change
    add_column :users, :confirmed, :boolean, default: false, nil: false
    add_column :users, :confirm_token, :string
  end
end
