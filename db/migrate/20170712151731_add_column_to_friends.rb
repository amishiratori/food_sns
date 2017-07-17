class AddColumnToFriends < ActiveRecord::Migration[5.1]
  def change
    add_column :friends, :friend_user_id, :integer
  end
end
