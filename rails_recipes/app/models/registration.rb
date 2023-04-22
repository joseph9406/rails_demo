class Registration < ApplicationRecord
  # ***** 16-1 需求和 Model 設計 *****
  STATUS = ["pending", "confirmed"]  
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id

  # ***** 17-3 自訂義資料驗證的錯誤顯示 *****
  validate :check_event_status, :on => :create 


  #validates_presence_of :name, :email, :cellphone, :bio  # ***** 16-8 有條件的表單驗證
  # ***** 16-8 有條件的表單驗證 *****
  attr_accessor :current_step
  validates_presence_of :name, :email, :cellphone, :if => :should_validate_basic_data?
  validates_presence_of :name, :email, :cellphone, :bio, :if => :should_validate_all_data?


  before_validation :generate_uuid, :on => :create

  belongs_to :event
  belongs_to :ticket
  belongs_to :user, :optional => true

  def to_param
    self.uuid
  end  

  protected

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def should_validate_basic_data?
    current_step == 2  # 只有做到第二步需要驗證
  end

  def should_validate_all_data?
    current_step == 3 || status == "confirmed"  # 做到第三步，或最後狀態是 confirmed 時需要驗證
  end

  def check_event_status
    if self.event.status == "draft"
      # 驗證不通過時，會用errors.add 增加錯誤訊息，第一個參數是字段名稱，第二個參數是錯誤訊息
      # 因為表單上並沒有 event_id 這個輸入框，所以就算寫成 errors.add(:event_id, "活動尚未開放報名") 
      # 也沒有地方顯示出來。依照慣例，任何不屬於某個字段的錯誤，我們會放在 :base 上。
      errors.add(:base, "活動尚未開放報名")
    end
  end
  
end
