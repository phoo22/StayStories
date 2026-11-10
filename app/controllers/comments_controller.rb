class CommentsController < ApplicationController
  before_action :require_login

  def create
    @post = Post.find(params[:post_id])
    @comment = current_user.comments.build(comment_params)
    @comment.post = @post

    if @comment.save
      redirect_to post_path(@post), notice: "Comment added successfully!"
    else
      redirect_to post_path(@post), alert: "Comment cannot be blank."
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find_by(id: params[:id])

  unless @comment
    redirect_to post_path(@post), alert: "Comment not found."
    return
  end

    if @comment.user_id == current_user.id
      @comment.destroy
      redirect_to post_path(@post), notice: "Comment deleted successfully!"
    else
      redirect_to post_path(@post), alert: "You cannot delete this comment."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def require_login
    unless current_user
      redirect_to new_sessions_path, alert: "Please sign in first."
    end
  end
end
