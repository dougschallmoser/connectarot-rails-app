class UsersController < ApplicationController

  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :require_login, only: [:edit, :update, :destroy]
  before_action only: [:edit, :update, :destroy] do 
      require_authorization(@user)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id 
      flash[:message] = "Account successfully created. You are now logged in."
      redirect_to user_entries_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user && @user.id == session[:user_id]
      self.authenticate_and_update_info(@user)
    else
      redirect_to user_entries_path(@user)
    end
  end

  def destroy
    @user.destroy 
    redirect_to root_path
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
    
end