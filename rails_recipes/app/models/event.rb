class Event < ApplicationRecord
    validates_presence_of :name    
    before_validation :generate_friendly_id, :on => :create

    def to_param
      #"#{self.id}-#{self.name}"
      self.friendly_id
    end

    STATUS = ["draft","public","private"]
    validates_inclusion_of :status, :in => STATUS  # 檢查模型屬性是否包含在指定的值範圍內。
    
    belongs_to :category, :optional => true

    #has_many :tickets, :dependent => :destroy
    has_many :tickets, :dependent => :destroy, :inverse_of  => :event  # 某些版本的 Rails 有個 accepts_nested_attributes_for 的bug 讓 has_many 故障了，需要額外補上inverse_of 參數，不然存儲時會找不到 tickets
    accepts_nested_attributes_for :tickets, :allow_destroy => true, :reject_if => :all_blank

    # ***** 15. 自訂列表順序
    include RankedModel
    ranks :row_order

    # ***** 16-1 需求和 Model 設計 *****
    has_many :registrations, :dependent => :destroy


    protected

    def generate_friendly_id
      self.friendly_id ||= SecureRandom.uuid
    end   

end
