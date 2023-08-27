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
          other_attributes: {} # TODO
        )
        @current_decision = decision
        @current_decision.created_by = current_decision_participant
        @current_decision.save!
      end
      render json: decision
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
      [:other_attributes, :description]
    end
  end
end
