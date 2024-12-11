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
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'create',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Decision',
                id: decision.id,
                truncated_id: decision.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
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
      ActiveRecord::Base.transaction do
        decision.save!
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'update',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Decision',
                id: decision.id,
                truncated_id: decision.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
      end
      render json: decision
    end

    private

    def updatable_attributes
      [:question, :description, :options_open, :deadline]
    end
  end
end
