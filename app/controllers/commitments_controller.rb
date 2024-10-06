class CommitmentsController < ApplicationController

  def new
    @page_title = "Coordinate"
    @page_description = "Coordinate with your team"
    @commitment = Commitment.new(
      title: params[:title],
    )
  end

  def create
    @commitment = Commitment.new(
      title: model_params[:title],
      description: model_params[:description],
      critical_mass: model_params[:critical_mass],
      deadline: Time.now + duration_param,
    )
    begin
      ActiveRecord::Base.transaction do
        @commitment.save!
        @current_commitment = @commitment
      end
      redirect_to @commitment.path
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = 'There was an error creating the commitment. Please try again.'
      render :new
    end
  end

  def show
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    @page_title = @commitment.title
    @page_description = "Coordinate with your team"
  end
end
