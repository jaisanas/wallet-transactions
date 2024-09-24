class TeamsController < ApplicationController
    before_action :authorize, only: [:create, :assign, :my_team]

    # == Description
    # This api will provide api to get team detail
    #
    # == Parameters:
    #
    # == Logic:
    # Create team object from sanitized team parameter
    # Update current_user to admin
    #
    # == Returns:
    # If object is sucessfully created in db record, it will render team json object
    # If failed then it will return error with error message 
    def my_team
        @team = current_user.team
        render json: @team
    end

    # == Description
    # This method will provide creating new team from active user
    #
    # == Parameters:
    # name::
    #   Team's name (String)
    #
    # == Logic:
    # Sanitized parameter input, only model's attributes is permitted
    # Create new user object from parameter input
    # Save object to execute active record and store in db
    #
    # == Returns:
    # If object is sucessfully created in db record, it will render team json object
    # If failed then it will return error with error message
    def create
        @team = Team.new(team_params)
        if @team.save!
            current_user.update(team: @team, user_type: "admin")
            render json: @team
        else
            render json: { errors: "failed to create new team" }, status: :unprocessable_entity
        end
    end

    def assign
       user = User.find(params[:user_id])
       team = current_user.team
       user.update(team: team)
       render json: { message: "user has beend assgined to team" }, status: :created
    end

    private
    def team_params
        params.require(:team).permit(:name)
    end
end
