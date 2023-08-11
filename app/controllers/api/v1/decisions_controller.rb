module Api::V1
  class DecisionsController < BaseController
    def create
      decision = Decision.create!(
        question: params[:question],
        description: params[:description],
        other_attributes: {} # TODO
      )
      
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
      [:other_attributes]
    end
  end
end
