class EventsController < ApplicationController
  def index
    #@events = Event.all
    @events = Event.rank(:row_order).all
  end

  def show
    #@events = Event.find(params[:id])    
    @event = Event.find_by_friendly_id!(params[:id])
  end
  
end
