module Api::V1
  class InfoController < BaseController

    def index
      # TODO Use routes to generate this (or swagger spec)
      render json: {
        name: 'Decisive Team API',
        version: '1.0.0', # TODO: Use config variable to track version
        routes: [
          {
            path: '/api/v1',
            methods: ['GET'],
          },
          {
            path: '/api/v1/decisions/:decision_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/decisions/:decision_id/options',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/decisions/:decision_id/options/:option_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/decisions/:decision_id/options/:option_id/approvals',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/decisions/:decision_id/options/:option_id/approvals/:approval_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/decisions/:decision_id/results',
            methods: ['GET'],
          },
        ]
      }
    end

    private

    def current_resource_model
      nil
    end
  end
end