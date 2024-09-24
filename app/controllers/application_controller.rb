class ApplicationController < ActionController::API
    # == Description
    #   This method will provide functionality to set current user session
    #
    # == Parameters:
    #
    # == Logic:
    #   Find user by id that is stored in session
    #   Set current_user with fetched user
    #
    # == Returns:
    #
    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end
    
    # == Description
    #   This method will provide functionality to check if user is logged in
    #
    # == Parameters:
    #
    # == Logic:
    #   Check if current_user is not nil
    #
    # == Returns:
    #
    def logged_in?
        !!current_user
    end
    
    # == Description
    #   This method will provide functionality to validate if user is currently logged in
    #
    # == Parameters:
    #
    # == Logic:
    #   Check if user is logged in
    #
    # == Returns:
    #   If user is not login then it will return error with error message
    def authorize
        unless logged_in?
            render json: { error: 'You must be logged in to access this resource' }, status: :unauthorized
        end
    end
end
