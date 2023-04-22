class CreateHosts < ActiveRecord::Migration[7.0]
  def change
    create_table :hosts do |t|
      t.string :fqdn
      t.string :ip_address
      t.string :os_family
      t.string :os_version
      t.integer :group_id

      t.timestamps
    end
  end
end
