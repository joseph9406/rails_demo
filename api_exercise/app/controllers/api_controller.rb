class ApiController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # ***** 4-4 設置 current_user *****
  before_action :authenticate_user_from_token

  def authenticate_user_from_token
    if params[:auth_token].present?
      user = User.find_by_authentication_token(params[:auth_token])
      sign_in(user, store: false) if user
      
    end
  end
end
