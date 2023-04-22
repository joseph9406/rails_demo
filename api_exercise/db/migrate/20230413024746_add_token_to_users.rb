class AddTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :authentication_token, :string
    add_index :users, :authentciation_token, :unique => true
    
    User.find_each |u| do
      puts "Generate user #{u.id} token"
      u.generate_authentication_token

      '''
      u.save! 用於儲存已變更的 u 物件至資料庫中。save! 方法會儲存物件至資料庫，並檢查是否成功儲存，
      如果儲存失敗會拋出例外錯誤讓程式碼停止執行，因此這個方法通常會用於必須確保儲存成功的情況。
            
      update 方法用於更新資料庫中已存在的紀錄，因此它需要指定要更新的欄位和值。
      u.generate_authentication_token 方法中已經更新了 u 物件的 authentication_token 欄位，
      因此只需要使用 save! 方法來儲存已變更的物件即可，並不需要使用 update 方法。
      '''
      u.save!  # save! 方法在保存失敗時會引發一個異常 ActiveRecord::RecordInvalid。
    end
  end
end

