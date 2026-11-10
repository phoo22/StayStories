class PostsController < ApplicationController
  before_action :require_login, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_owned_post, only: [ :edit, :update, :destroy ]

  def index
    @posts = Post.order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to posts_path, notice: "Post created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = post_params.except(:images)

    if @post.update(attributes)
      if post_params[:images].present?
        @post.images.attach(post_params[:images])
      end

      redirect_to post_path(@post), notice: "Post updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted successfully!"
  end

  private

  def require_login
    unless current_user
      redirect_to new_sessions_path, alert: "Please log in first."
    end
  end

  def set_owned_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :location, images: [])
  end
end
