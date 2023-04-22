class Reservation < ApplicationRecord
  validates_presence_of :booking_code, :train_id, :seat_number
  validates_uniqueness_of :seat_number, :scope => :train_id

  belongs_to :train
  
  before_validation :generate_booking_code, :on => :create

  def generate_booking_code
    self.booking_code = SecureRandom.uuid
  end

  # ***** 4. 實作認證 API *****
  belongs_to :user
end
