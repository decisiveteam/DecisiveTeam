module Api::V1
  class ScratchpadController < BaseController
    def show
      render json: {
        text: current_user.scratchpad['text'],
        custom_json: current_user.scratchpad['custom_json'],
      }
    end

    def update
      if has_text_param? || params.has_key?(:custom_json)
        tu = current_user.tenant_user
        tu.settings['scratchpad']['text'] = params[:text] if has_text_param?
        tu.settings['scratchpad']['custom_json'] = params[:custom_json] if params.has_key?(:custom_json)
        tu.save!
        render json: current_user.scratchpad
      else
        render status: 400, json: { error: '"text" or "custom_json" is required' }
      end
    end

    def append
      if has_text_param? && !params.has_key?(:custom_json)
        tu = current_user.tenant_user
        tu.settings['scratchpad']['text'] += "\n" + params[:text]
        tu.save!
        render json: current_user.scratchpad
      elsif params.has_key?(:custom_json)
        render status: 400, json: { error: 'Cannot append to custom_json' }
      else
        render status: 400, json: { error: 'Text is required' }
      end
    end

    private

    def has_text_param?
      params[:text] && params[:text].is_a?(String)
    end

    def current_resource_model
      User
    end
  end
end
