class GroupsController < ApplicationController
  def index    
    @groups = Group.page(params[:page]).per(5)    
  end

  def create
    @group = Group.new(group_params)    
    if @group.save      
      flash.now[:notice] = "#{@group.name} 成功新增 !"
      redirect_to groups_url
    else
      flash.now[:notice] = "#{@group.name} 成功新增 !"
      render :index
    end
  end

  def edit
    @group = Group.find(params[:id])    
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      flash[:notice] = "完成修改 #{@group.name} !"
      redirect_to groups_path
    else
      render :edit
      flash[:notice] = "修改失敗"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    flash[:notice] = "成功刪除 #{@group.name}"
    redirect_to groups_path
  end

  def check_groups
    total = 0

    Array(params[:group_ids]).each do |group_id|
      event = Event.find(event_id)
      #event.destroy
      #total += 1
      if params[:commit] == I18n.t(:bulk_update)
        event.status = params[:event_status]
        if event.save
          total += 1
        end
      elsif params[:commit] == I18n.t(:bulk_delete)
        event.destroy
        total += 1
      end
    end

  end

  def hosts
    ids = Array(params[:group_ids])  # 這個值在 params 中是以字符串形式存儲的，因此需要使用 Array() 方法將它轉換為真正的數組。
    @groups = Group.where(id: params[:group_ids])
    @hosts = Host.where(group_id: @groups.pluck(:id))

    '''
    events = ids.map{ |i| Event.find_by_id(i) }.compact  # compact 方法過濾掉 nil 值
  
    if params[:commit] == "Publish"
      events.each{ |e| e.update( :status => "published" ) }
    elsif params[:commit] == "Delete"
      events.each{ |e| e.destroy }
    end
  
    redirect_to events_url
    '''
end

  protected 

  def group_params
    params.require(:group).permit(:name, :description, :group_ids =>[])
  end


  
end
