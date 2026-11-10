class UsersController < ApplicationController
  before_action :require_login, only: [ :edit, :update, :destroy ]
  before_action :set_current_user, only: [ :edit, :update, :destroy ]

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

  def edit
  end

  def update
    attributes = user_params

    if attributes[:password].blank?
      attributes = attributes.except(:password, :password_confirmation)
    end

    if @user.update(attributes)
      redirect_to user_path(@user), notice: "Profile updated successfully!"

    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    reset_session
    redirect_to new_user_path, notice: "Your account has been deleted."
  end

  private

  def require_login
    unless current_user
      redirect_to new_sessions_path, alert: "Please log in first."
    end
  end

  def set_current_user
    @user = current_user
    unless @user && @user.id == params[:id].to_i
      redirect_to root_path, alert: "You are not authorized."
    end
  end

  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
