class Host < ApplicationRecord
  validates_presence_of :fqdn, :if_address
  
  belongs_to :group, :optional => true
end
