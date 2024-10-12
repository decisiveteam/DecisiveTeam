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
    @commitment_participant = current_commitment_participant
    @participants_list_limit = 10
    return render '404', status: 404 unless @commitment
    @page_title = @commitment.title
    @page_description = "Coordinate with your team"
  end

  def status_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    render partial: 'status'
  end

  def join_and_return_status_partial
    @commitment = current_commitment
    @commitment_participant = current_commitment_participant
    return render '404', status: 404 unless @commitment && @commitment_participant
    @commitment_participant.committed = true if params[:committed].to_s == 'true'
    @commitment_participant.name = params[:name]
    @commitment_participant.save!
    render partial: 'status'
  end

  def participants_list_items_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    @participants_list_limit = params[:limit].to_i if params[:limit].present?
    @participants_list_limit = 20 if @participants_list_limit < 1
    render partial: 'participants_list_items'
  end
end
