module Api::V1
  class DecisionsController < BaseController
    def index
      render_404
    end
  
    def create
      ActiveRecord::Base.transaction do
        decision = Decision.create!(
          question: params[:question],
          description: params[:description],
          options_open: params[:options_open] || true,
          auth_required: params[:auth_required] || false,
          deadline: params[:deadline],
          other_attributes: params[:other_attributes] || {},
        )
        @current_decision = decision
        @current_decision.created_by = current_decision_participant
        @current_decision.save!
        render json: decision
      rescue ActiveRecord::RecordInvalid => e
        # TODO - Detect specific validation errors and return helpful error messages
        render json: { error: 'There was an error creating the decision. Please try again.' }, status: 400
      end
    end

    def update
      decision = Decision.find_by(id: params[:id])
      return render json: { error: 'Decision not found' }, status: 404 unless decision
      updatable_attributes.each do |attribute|
        decision[attribute] = params[attribute] if params.has_key?(attribute)
      end
      decision.save!
      render json: decision
    end

    private

    def updatable_attributes
      [:question, :description, :options_open, :auth_required, :deadline, :other_attributes]
    end
  end
end
