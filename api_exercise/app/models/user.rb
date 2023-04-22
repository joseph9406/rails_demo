class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
      
  # ***** 4. 實作認證 API *****  
  has_many :reservations

  # 創建一個新的資料庫記錄之前自動調用的方法。它可以用於在保存資料之前修改模型屬性，設置默認值或驗證模型。
  before_create :generate_authentication_token

  def generate_authentication_token
    self.authentication_token = Devise.friendly_token
    #self.auth_token = SecureRandom.hex  # 從 chatGPT 上看到的例子
  end

  '''
  當使用者上傳一個圖片時，CarrierWave 會將圖片保存到指定的路徑,該路徑會存儲在 User.avatar(自定義屬性)。
  將 avatar 屬性關聯到 AvatarUploader 上傳器類別。 這表示當使用者上傳一個圖片時，
  CarrierWave 會自動調用 AvatarUploader 類別中的方法在來處理圖片，例如：縮放、裁剪、旋轉等等。
  '''
  mount_uploader :avatar, AvatarUploader

end
