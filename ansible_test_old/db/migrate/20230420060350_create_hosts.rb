class CreateHosts < ActiveRecord::Migration[7.0]
  def change
    create_table :hosts do |t|
      t.string :name
      t.string :ip_address
      t.string :os_family
      t.string :os_version

      t.timestamps
    end
  end
end
