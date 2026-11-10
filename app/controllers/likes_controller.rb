class LikesController < ApplicationController
  before_action :require_login

  def create
    @post = Post.find(params[:post_id])

    @like = current_user.likes.find_or_create_by(post: @post)

    redirect_back fallback_location: post_path(@post)
  end

  def destroy
    @post = Post.find(params[:post_id])

    @like = current_user.likes.find_by(post: @post)
    @like&.destroy

    redirect_back fallback_location: post_path(@post)
  end

  private

  def require_login
    unless current_user
      redirect_to new_sessions_path, alert: "Please sign in first."
    end
  end
end
