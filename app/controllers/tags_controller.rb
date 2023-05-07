class TagsController < ApplicationController
  
    def new
      @tag = Tag.new(
        team_id: current_team.id,
        name: params[:name],
        description: params[:description]
      )
    end
  
    def create
      @tag = Tag.new(
        team_id: current_team.id,
        name: tag_params[:name],
        description: tag_params[:description]
      )
  
      if @tag.save
        redirect_to "/teams/#{current_team.id}/tags/#{@tag.name}"
      else
        flash.now[:alert] = 'There was an error creating the tag. Please try again.'
        render :new
      end
    end
  
    def index
      @tags = Tag.accessible_by(current_user).where(team: current_team)
    end
  
    def show
      if Tag.is_decision_tag?(params[:name])
        redirect_to "/teams/#{current_team.id}/decisions/#{params[:name]}"
        return
      end
      @tag = Tag.accessible_by(current_user).where(team: current_team).find_by(name: params[:name])
      if @tag.nil?
        @current_team ||= current_team
        @name = params[:name]
        render '404', status: 404
      end
    end
  
    private
  
    def tag_params
      params.require(:tag).permit(:name, :description)
    end
  end
  