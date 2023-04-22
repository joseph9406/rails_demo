class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.integer :event_id, :integer, :index => true
      t.string :name
      t.text :description
      t.integer :price
      t.timestamps
    end
  end
end
