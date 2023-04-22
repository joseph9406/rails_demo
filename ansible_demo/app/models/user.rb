class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = ["admin", "editor"]

  def display_name
    self.email.split("@").first
  end
  
  def is_admin?
    self.role == "admin"
  end

  def is_editor?
    ["admin", "editor"].include?(self.role)  # 如果是 admin 的話，當然也有 editor 的權限
  end
  
end
