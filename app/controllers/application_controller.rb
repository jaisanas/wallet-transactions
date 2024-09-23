class ApplicationController < ActionController::API
    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end
    
    def logged_in?
        !!current_user
    end
    
    def authorize
        unless logged_in?
            render json: { error: 'You must be logged in to access this resource' }, status: :unauthorized
        end
    end
end
