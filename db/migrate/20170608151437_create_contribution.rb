class CreateContribution < ActiveRecord::Migration[5.1]
  def change
    create_table :contributions do |t|
      t.references :user
      t.string  :rest_name 
      t.string  :rest_img 
      t.string  :rest_url 
      t.string  :memo 
      t.string  :who 
      t.integer  :year 
      t.integer  :month 
      t.integer  :day 
      t.datetime  :created_at , null: false
      t.datetime  :updated_at , null: false
    end
  end
end
