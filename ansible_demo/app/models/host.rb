class Host < ApplicationRecord
  validates_presence_of :fqdn, :ip_address
  
  belongs_to :group, :optional => true
end
