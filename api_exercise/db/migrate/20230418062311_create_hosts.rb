class CreateHosts < ActiveRecord::Migration[7.0]
  def change
    create_table :hosts do |t|
      t.string :name
      t.string :os
      t.string :cpu
      t.string :memory
      t.string :disk

      t.timestamps
    end
  end
end
