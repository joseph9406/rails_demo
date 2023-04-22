class PostsController < ApplicationController
  # 在執行 create 和 destroy 方法前,先執行指竹的方。
  # 所以這段的用意是,在執行create和destroy之前,先檢查使用者是否登入比驗證是是,
  # 若未通過身份驗證, 則導向登入頁面或顯示錯誤信息。
  before_action :authenticate_user!, :only => [:create, :destroy]

  def index    
    #@posts = Post.order("id DESC").all    # 新貼文放前面
    @posts = Post.order("id DESC").limit(10)

    if params[:max_id]
        @posts = @posts.where( "id < ?", params[:max_id])
    end

    respond_to do |format|
        format.html  # 如果客戶端要求 HTML，則回傳 index.html.erb
        format.js    # 如果客戶端要求 JavaScript，回傳 index.js.erb
    end
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    #@post.save
    
    if @post.save
      render json: { post: render_to_string(partial: 'post', locals: { post: @post }) }
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  
  end

  def destroy
    @post = current_user.posts.find(params[:id])  # 只能刪除自己的貼文
    @post.destroy

    #redirect_to posts_path
    #render :js => "alert('OK !');"   
    render :json => { :id => @post.id }
  end

  def update
    @post = Post.find(params[:id])
    @post.update!( post_params )

    render :json => { :id => @post.id, :message => "ok"}
  end

  def like
    @post = Post.find(params[:id])
    unless @post.find_like(current_user)  # 如果已經按讚過了，就略過不再新增
      Like.create( :user => current_user, :post => @post)
    end

    #redirect_to posts_path
  end

  def unlike
    @post = Post.find(params[:id])
    like = @post.find_like(current_user)
    like.destroy

    #redirect_to posts_path
    render "like"
  end
    
  # ***** 4-4 使用核選方塊(checkbox)做開關 *****
  def toggle_flag
    @post = Post.find(params[:id])

    if @post.flag_at
      @post.flag_at = nil
    else
      @post.flag_at = Time.now
    end

    @post.save!

    render :json => { :message => "ok", :flag_at => @post.flag_at, :id => @post.id }
  end

  # ***** 4-10 jQuery Plugin 整合示範(cont) *****
  def rate
    @post = Post.find(params[:id])

    existing_score = @post.find_score(current_user)
    if existing_score
      existing_score.update( :score => params[:score] )
    else
      @post.scores.create( :score => params[:score], :user => current_user )
    end

    render :json => { :average_score => @post.average_score }
  end

  protected

  def post_params
    params.require(:post).permit(:content, :flag_at, :category_id)
  end

end
