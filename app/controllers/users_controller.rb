class UsersController < ApplicationController
  before_action :authorize, only: [:profile]

  # == Description
  # This method adds two numbers together.
  #
  # == Parameters:
  # num1::
  #   The first number (Integer).
  # num2::
  #   The second number (Integer).
  #
  # == Returns:
  # An Integer that is the sum of the two numbers.
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

  def profile
      @user = User.find(current_user.id)
      render json: @user.as_json(except: [:password_digest])
  end
    
  private
  def user_params
      params.require(:user).permit(:name, :birth_date, :email, :phone_number,:address, :user_type, :password, :password_confirmation)
  end
end
