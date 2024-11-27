module Api::V1
  class CommitmentsController < BaseController
    def index
      index_not_supported_404
    end

    def create
      ActiveRecord::Base.transaction do
        commitment = Commitment.create!(
          title: params[:title],
          description: params[:description],
          deadline: params[:deadline],
          critical_mass: params[:critical_mass],
          created_by: current_user,
        )
        render json: commitment.api_json
      rescue ActiveRecord::RecordInvalid => e
        # TODO - Detect specific validation errors and return helpful error messages
        render json: { error: 'There was an error creating the commitment. Please try again.' }, status: 400
      end
    end

    def update
      note = current_commitment
      return render json: { error: 'Commitment not found' }, status: 404 unless commitment
      updatable_attributes.each do |attribute|
        commitment[attribute] = params[attribute] if params.has_key?(attribute)
      end
      if commitment.changed?
        commitment.updated_by = current_user
        commitment.save!
      end
      render json: commitment.api_json
    end

    private

    def updatable_attributes
      [:title, :description, :deadline, :critical_mass]
    end
  end
end
