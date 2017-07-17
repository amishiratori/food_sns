class CreateTalkmessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string :body
      t.references :users
      t.references :rooms
      t.timestamps null: false
    end
  end
end
