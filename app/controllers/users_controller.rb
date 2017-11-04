class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  def new
  end

  def create
    user = User.create(email: params[:email], password: params[:password])
    login(user)
    redirect_to user_path(user)
  end

  def show
    @user = User.find_by(id: params[:id])
  end

end
