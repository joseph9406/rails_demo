class AddGroupIdToHosts < ActiveRecord::Migration[7.0]
  def change
    add_column :hosts, :group_id, :string 
  end
end
