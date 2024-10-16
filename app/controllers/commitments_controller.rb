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
    @commitment_participant = current_commitment_participant
    @commitment_participant_name = @commitment_participant.name || (current_user ? current_user.name : '')
    @participants_list_limit = 10
    @page_title = @commitment.title
    @page_description = "Coordinate with your team"
  end

  def status_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    render partial: 'status'
  end

  def join_and_return_partial
    # Must be logged in to join
    unless current_user
      return render message: 'You must be logged in to join.', status: 401
    end
    @commitment = current_commitment
    if @commitment.closed?
      return render message: 'This commitment is closed.', status: 400
    end
    @commitment_participant = current_commitment_participant
    @commitment_participant_name = @commitment_participant.name || current_user.name
    @commitment_participant.committed = true if params[:committed].to_s == 'true'
    @commitment_participant.name = @commitment_participant_name
    @commitment_participant.save!
    render partial: 'join'
  end

  def participants_list_items_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    @participants_list_limit = params[:limit].to_i if params[:limit].present?
    @participants_list_limit = 20 if @participants_list_limit < 1
    render partial: 'participants_list_items'
  end

  def edit_display_name_and_return_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    ActiveRecord::Base.transaction do
      @commitment_participant = current_commitment_participant
      current_user.name = params[:name]
      @commitment_participant.name = params[:name]
      current_user.save!
      @commitment_participant.save!
    end
    @commitment_participant_name = @commitment_participant.name
    render partial: 'join'
  end

  private

  def current_app
    return @current_app if defined?(@current_app)
    @current_app = 'coordinated'
    @current_app_title = 'Coordinated Team'
    @current_app_description = 'fast group coordination'
    @current_app
  end
end
