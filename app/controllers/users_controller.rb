class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path, notice: "Account created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by(id: params[:id])

    unless @user
      redirect_to posts_path, alert: "User not found."
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
