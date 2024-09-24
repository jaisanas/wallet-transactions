class SessionsController < ApplicationController
    def create
      user = User.find_by(email: params[:email])
      
      # Authenticate the user using bcrypt's `authenticate` method
      if user && user.authenticate(params[:password])
        # Save the user ID in the session
        session[:user_id] = user.id
        render json: { message: "Sign in is successful"}, status: :created
      else
        render json: { errors: "cannot login" }, status: :unprocessable_entity
      end
    end
    
    def destroy
      # Log out the user by clearing the session
      session[:user_id] = nil
      render json: { message: "you have logout"}, status: :ok
    end
end