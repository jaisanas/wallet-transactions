class UsersController < ApplicationController
  before_action :authorize, only: [:profile]

  # == Description
  # This method is used to create new user or as a sign up
  #
  # == Parameters:
  #name::
  #   full name that consist of first name, middle name(optional), and last_name as a sing string(String).
  #birth_date::
  #   date of birth user (Datetime).
  #phone_number::
  #   phone number should be started with country code such as 62 for indonesia (String)
  #address::
  #   user's address(String)
  #user_type::
  #   allowed value for user_type is only admin and non-admin (String)
  #password::
  #   user's password (String)
  #password_confirmation::
  #   password_confirmation must match with password (String)
  #
  # == Logic:
  #   Sanitized parameter input, only model's attributes and password is permitted
  #   Create new user object from parameter input
  #   Save object to execute active record and store in db
  #
  # == Returns:
  #   If object is sucessfully created in db record, it will render user json object
  #   If failed then it will return error with error message 
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

  # == Description
  # This method will provide api to get current user detail (user that is currently login)
  #
  # == Parameters:
  #
  # == Logic:
  #   Find user by user id from active session
  #   Return user json object by excluding password_digest
  #   Excluding password digest will minimize security vulnerability
  #
  # == Returns:
  #   Return user json object by excluding password_digest
  # 
  def profile
      render json: current_user.as_json(except: [:password_digest])
  end
    
  private
  def user_params
      params.require(:user).permit(:name, :birth_date, :email, :phone_number,:address, :user_type, :password, :password_confirmation)
  end
end
