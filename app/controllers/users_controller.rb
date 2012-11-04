class UsersController < ApplicationController
  before_filter :signed_in_user, except: [:show, :new, :create]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:destroy]
  before_filter :to_root_if_signed_in, only: [:new, :create]
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render :new
    end
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Saved"
      sign_in @user
      redirect_to @user
    else
      render :edit
    end
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def destroy
    @user = User.find_by_id!(params[:id])
    unless @user.admin?
      @user.destroy
      flash[:success] = "User: #{@user.name} deleted"
    else
      flash[:error] = "Cannot delete admin user: #{@user.name}"
    end
    redirect_to users_path
  end
  
  private
  def to_root_if_signed_in
    redirect_to root_path if signed_in?
  end
    
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
