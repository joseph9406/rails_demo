class AddNameToCategories < ActiveRecord::Migration[7.0]
  def change      
    add_column :categories, :name, :string

    add_column :posts, :category_id, :integer
    add_index :posts, :category_id
  end
end
