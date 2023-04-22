class Ticket < ApplicationRecord
  validates_presence_of :name, :price
  belongs_to :event

  # ***** 16-1 需求和 Model 設計 *****
  has_many :registrations

end
