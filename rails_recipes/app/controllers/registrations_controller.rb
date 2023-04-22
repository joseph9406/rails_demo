class RegistrationsController < ApplicationController
    before_action :find_event

    def new
    end

    def create
      @registration = @event.registrations.new(registration_params)
      @registration.ticket = @event.tickets.find( params[:registration][:ticket_id] )
      @registration.status = "pending"
      @registration.user = current_user
      @registration.current_step = 1   # current_stap 是定義在 registration model 裏的實例變量, 用來記錄新增的步驟

      if @registration.save
        #redirect_to event_registration_path(@event, @registration)
        redirect_to step2_event_registration_path(@event, @registration)
      else
        # 本來的 flash 搭配的是 redirect，這會在跳轉後清空 flash 訊息(所以只會顯示一次)。 
        # 這裡因為並不是 redirect 跳轉，而是用 render 顯示頁面，這種情況要改用 flash.now。
        flash.now[:alert] = @registration.errors[:base].join("、")
        render :new
      end
    end

    def step1
      @registration = @event.registrations.find_by_uuid(params[:id])      
    end

    def step1_update
      @registration = @event.registrations.find_by_uuid(params[:id])
      @registration.current_step = 1

      if @registration.update(registration_params)
        redirect_to step2_event_registration_path(@event, @registration)
      else
        render :step1
      end
    end
    
    def step2
      @registration = @event.registrations.find_by_uuid(params[:id])
    end

    def step2_update
      @registration = @event.registrations.find_by_uuid(params[:id])
      @registration.current_step = 2
      
      if @registration.update(registration_params)
        redirect_to step3_event_registration_path(@event, @registration)
      else
        render :step2
      end
    end

    def step3
      @registration = @event.registrations.find_by_uuid(params[:id])
    end

    def step3_update
      @registration = @event.registrations.find_by_uuid(params[:id])
      @registration.status = "confirmed"
      @registration.current_step = 3

      if @registration.update(registration_params)
        flash[:notice] = "報名成功"
        redirect_to event_registration_path(@event, @registration)
      else
        render :step3
      end
    end

    def show
      @registration = @event.registrations.find_by_uuid(params[:id])
    end

    protected

    def find_event  
      @event = Event.find_by_friendly_id(params[:event_id])
    end

    def registration_params
      params.require(:registration).permit(
        :ticket_id, 
        :name, 
        :email, 
        :cellphone, 
        :website, 
        :bio
      )
    end
end
