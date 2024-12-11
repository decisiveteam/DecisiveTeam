module Api::V1
  class CustomDataController < BaseController
    def index
      render json: current_table.api_json(include: includes_param)
    end

    def show
      record = current_resource
      unless record
        return render status: 404, json: { error: "Record not found" }
      end
      record.create_read_history_event!(
        request_context: request_context_for_history_events,
        user: current_user
      )
      render json: record.api_json
    end

    def create
      ActiveRecord::Base.transaction do
        record = CustomDataRecord.create_with_history_event!(
          attributes: {
            table_name: params[:table_name],
            custom_uid: params[:custom_uid],
            data: params[:data],
            belongs_to: [parent_record].compact,
          },
          request_context: request_context_for_history_events,
          user: current_user
        )
        if has_parent? && parent_record.nil?
          raise ActiveRecord::RecordNotFound
        end
        render json: record.api_json
      rescue ActiveRecord::RecordInvalid => e
        # Loop through the errors and return a helpful error message
        message = ''
        e.record.errors.each do |attribute, error|
          message += "#{attribute.to_s.humanize} #{error}. "
        end
        render status: 400, json: { error: message }
      rescue ActiveRecord::RecordNotUnique => e
        render status: 409, json: { error: "Record already exists with table name '#{params[:table_name]}' and custom_uid '#{params[:custom_uid]}'" }
      rescue ActiveRecord::RecordNotFound => e
        render status: 404, json: { error: "Record not found for '#{params[:parent_table_name]}/#{params[:parent_id]}'" }
      end
    end

    def update
      record = current_resource
      return render status: 404, json: { error: 'Record not found' } unless record
      if params[:custom_uid] && record.custom_uid != params[:custom_uid].to_s
        return render status: 409, json: { error: "Cannot change custom_uid" }
      end
      ActiveRecord::Base.transaction do
        record.update_with_history_event!(
          attributes: {
            data: params[:data],
          },
          request_context: request_context_for_history_events,
          user: current_user
        )
        render json: record.api_json
      rescue ActiveRecord::RecordInvalid => e
        # Loop through the errors and return a helpful error message
        message = ''
        e.record.errors.each do |attribute, error|
          message += "#{attribute.to_s.humanize} #{error}. "
        end
        render status: 400, json: { error: message }
      end
    end

    def destroy
      record = current_resource
      return render status: 404, json: { error: 'Record not found' } unless record
      record.destroy_with_history_event!(
        request_context: request_context_for_history_events,
        user: current_user
      )
      render json: { message: 'Record deleted' }
    end

    def history
      record = current_table.find_record(params[:id], include_deleted: true) # Only history events are shown for deleted records
      return render status: 404, json: { error: 'Record not found' } unless record
      render json: record.history_events.order(happened_at: :desc).map(&:api_json)
    end

    # NOTE Do not name this method "config" as it conflicts with ActionController::Base
    def configuration
      render json: {}
    end

    def info
      tables = CustomDataTable.all.map do |table|
        {
          table_name: table.name,
          record_count: table.record_count,
          last_updated: table.last_updated,
          schema: table.schema,
        }
      end
      render json: {
        tables: tables,
      }
    end

    private

    def current_resource
      return @current_resource if defined?(@current_resource)
      table = current_table
      return table if table.is_a?(String) # Return early if there was an error
      @current_resource = table.find_record(params[:id])
    end

    def current_table
      return @current_table if defined?(@current_table)
      table = CustomDataTable.find_by(name: params[:table_name]) || CustomDataTable.new(name: params[:table_name])
      if has_parent?
        unless parent_record
          return render status: 404, json: { error: "No record found for table name '#{params[:parent_table_name]}' and id '#{params[:parent_id]}'" }
        end
        table.scope_to_parent(parent_record)
      end
      @current_table = table
    end

    def parent_record
      return @parent_record if defined?(@parent_record)
      if has_parent?
        parent_table = CustomDataTable.find_by(name: params[:parent_table_name])
        @parent_record = parent_table&.find_record(params[:parent_id])
      else
        @parent_record = nil
      end
    end

    def has_parent?
      params[:parent_id]
    end

    def current_resource_model
      # CustomDataRecord
      User
    end
  end
end
