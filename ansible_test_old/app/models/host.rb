class Host < ApplicationRecord
    validates_presence_of :name   
    validates_presence_of :ip_address

    belongs_to :group, :optional => true 
end
