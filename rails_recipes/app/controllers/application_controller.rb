class ApplicationController < ActionController::Base
    before_action :set_locale
    before_action :set_timezone
    
    def set_locale
      # I18n.available_locales 返回一個可用的區域設置列表，即一個包含所有應用程序支持的區域設置符號的數組。       
      # 可以將 ["en", "zh-CN"] 設定為 VALID_LANG 放到 config/environment.rb 中
      if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )  # to_sym 將字串轉換為符號
        session[:locale] = params[:locale]
      end

      I18n.locale = session[:locale] || I18n.default_locale
    end

    def set_timezone
      if current_user && current_user.time_zone
        Time.zone = current_user.time_zone
      end
    end
end
