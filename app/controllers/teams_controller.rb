class TeamsController < ApplicationController
    before_action :authorize, only: [:create, :assign, :my_team]

    def my_team
        @team = current_user.team
        render json: @team
    end

    def create
        @team = Team.new(team_params)
        user = User.find(current_user.id)
        if @team.save!
            user.update(team: @team, user_type: "admin")
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
