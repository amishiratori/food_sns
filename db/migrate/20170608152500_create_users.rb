class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :user_id
      t.string :password_digest
      t.timestamps null: false
    end
  end
end
