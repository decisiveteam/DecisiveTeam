module Api::V1
  class DecisionsController < BaseController
    def index
      index_not_supported_404
    end

    def create
      ActiveRecord::Base.transaction do
        decision = Decision.create!(
          question: params[:question],
          description: params[:description],
          options_open: params[:options_open] || true,
          deadline: params[:deadline],
          created_by: current_user,
        )
        render json: decision
      rescue ActiveRecord::RecordInvalid => e
        # TODO - Detect specific validation errors and return helpful error messages
        render json: { error: 'There was an error creating the decision. Please try again.' }, status: 400
      end
    end

    def update
      decision = current_decision
      return render json: { error: 'Decision not found' }, status: 404 unless decision
      updatable_attributes.each do |attribute|
        decision[attribute] = params[attribute] if params.has_key?(attribute)
      end
      decision.updated_by = current_user
      decision.save!
      render json: decision
    end

    private

    def updatable_attributes
      [:question, :description, :options_open, :deadline]
    end
  end
end
