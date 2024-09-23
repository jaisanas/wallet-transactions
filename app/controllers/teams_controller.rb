class TeamsController < ApplicationController
    before_action :authorize, only: [:create]

    def create
        @team = Team.new(team_params)
        user = User.find(current_user.id)
        if @team.save!
            user.update(team: @team)
            render json: @team
        else
            render json: { errors: "failed to create new team" }, status: :unprocessable_entity
        end
    end

    private
    def team_params
        params.require(:team).permit(:name)
    end
end
