class GroupHostsController < ApplicationController
  before_action :set_groups

  def index     
    #@hosts = Host.where(group_id: @groups.pluck(:id))   
    @hosts = Host.where(params[:group_ids]) 
  end

  def show
    @host = Host.find(params[:id])
  end
  
  protected

  def set_groups    
    #@groups = Group.where(:id => :group_ids).includes(:host)
    @groups = Group.where(:id => :group_ids)
    # ...
  end
end
