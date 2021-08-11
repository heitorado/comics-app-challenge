class ApplicationController < ActionController::Base
  before_action :set_current_user

  private
  
  def set_current_user
    @user = session[:user_id].present? ? User.find(session[:user_id]) : User.create!

    session[:user_id] = @user.id
  end
end
