class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.string booking_code, :index => true
      t.integer train_id, :index => true
      t.string seat_number, :index => true
      t.integer user_id, :index => true
      t.string customer_name
      t.stirng customer_phone
      t.timestamps
    end
  end
end
