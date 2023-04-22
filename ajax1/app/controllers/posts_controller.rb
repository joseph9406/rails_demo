class PostsController < ApplicationController
  # 在執行 create 和 destroy 方法前,先執行指定的方法(這裏是指 authenticate_user!)。
  # 所以這段的用意是,在執行create和destroy之前,先檢查使用者是否登入比驗證是是,
  # 若未通過身份驗證, 則導向登入頁面或顯示錯誤信息。
  before_action :authenticate_user!, :only => [:create, :destroy]

  def index    
    @posts = Post.order("id DESC").all    # 新貼文放前面
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.save

    #redirect_to posts_path
  end

  def destroy
    @post = current_user.posts.find(params[:id])  # 只能刪除自己的貼文
    @post.destroy

    #redirect_to posts_path
    #render :js => "alert('OK !');"   
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
    

  protected

  def post_params
    params.require(:post).permit(:content)
  end

end
