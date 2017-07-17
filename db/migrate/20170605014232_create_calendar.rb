class CreateCalendar < ActiveRecord::Migration[5.1]
  def change
    create_table :calendars do |t|
      t.integer :year
      t.integer :month
      t.timestamps null: false
    end
  end
end
