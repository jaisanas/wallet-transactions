class UsersController < ApplicationController
  before_action :authorize, only: [:profile]

  def create
      @user = User.new(user_params)
      if @user.save!
        # Handle successful sign-up (e.g., log in user, redirect)
        render json: @user
      else
        # Handle sign-up error (e.g., render the form again with errors)
        render json: { errors: "failed to create new user" }, status: :unprocessable_entity
      end
  end

  def signin
      @user = User.find_by(email: params[:email])

      if @user&.authenticate(params[:password])  # Authenticate using bcrypt
      # Log in user (e.g., set session, redirect)
          render json: { message: "Sign in is successful"}, status: :created
      else
      # Handle invalid login (e.g., render the login form again with errors)
          render json: { errors: "cannot login" }, status: :unprocessable_entity
      end
  end

  def profile
      @user = User.find(current_user.id)
      render json: @user
  end
    
  private
  def user_params
      params.require(:user).permit(:name, :birth_date, :email, :phone_number,:address, :user_type, :password, :password_confirmation)
  end
end
