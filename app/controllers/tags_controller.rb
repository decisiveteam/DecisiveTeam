class TagsController < ApplicationController
    layout 'markdown'
  
    def new
      @tag = Tag.new(team_id: current_team.id)
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
      @tag = Tag.accessible_by(current_user).where(team: current_team).find_by(name: params[:name])
    end
  
    private
  
    def tag_params
      params.require(:tag).permit(:name, :description)
    end
  end
  