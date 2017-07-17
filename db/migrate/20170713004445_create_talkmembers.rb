class CreateTalkmembers < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
    end
    
    create_table :talkmembers do |t|
      t.references :users
      t.references :rooms
    end
  end
end
