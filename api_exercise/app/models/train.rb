class Train < ApplicationRecord
  validates_presence_of :number
  
  has_many :reservations

  # 產生所有位置從 1A~6C
  # ["1A", "1B", "1C", "2A", "2B", "2C", "3A", "3B", "3C",
  #  "4A", "4B", "4C", "5A", "5B", "5C", "6A", "6B", "6C"]
  SEATS = begin
    (1..6).to_a.map do |series|
      ["A","B","C"].map do |letter|
       "#{series}#{letter}"
      end
    end
  end.flatten

  def available_seats
    # TODO: 回傳有空的座位，這裡先暫時固定回傳一個陣列，等會再來處理
    #["1A", "1B", "1C", "1D", "1F"]
    # 所有 SEATS 扣掉已經訂位的資料
    return SEATS - self.reservations.pluck(:seat_number)
  end

  
end
