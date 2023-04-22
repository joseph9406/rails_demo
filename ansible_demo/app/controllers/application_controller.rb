class ApplicationController < ActionController::Base
  #before_action :authenticate_user!
  before_action :set_locale

  protected

  def set_locale
    # 可以將 ["en", "zh-CN"] 設定為 VALID_LANG 放到 config/environment.rb 中
    if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )
      session[:locale] = params[:locale]
    end

    I18n.locale = session[:locale] || I18n.default_locale
  end

  def require_editor!
    #if current_user.role != "editor" && current_user.role != "admin"
    unless current_user.is_editor?
      #flash.now[:alert] = "您的權限不足"
      flash[:alert] = "您的權限不足"
      redirect_to root_path
      #redirect_back(fallback_location: root_path)
    end
  end

  def require_admin!
    #if current_user.role != "admin"
    unless current_user.is_admin?
      #flash.now[:alert] = "您的權限不足"
      flash[:alert] = "您的權限不足"
      redirect_to root_path
      #redirect_back(fallback_location: root_path)
    end
  end
  
end
