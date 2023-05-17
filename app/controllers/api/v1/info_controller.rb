module Api::V1
  class InfoController < BaseController
    # InfoController is a special controller that does not require authentication
    # or authorization. It only provides public information about the API.
    skip_before_action :verify_authenticity_token, only: [:index]
    skip_before_action :doorkeeper_authorize!, only: [:index]
    skip_before_action :authenticate_user!, only: [:index]
    skip_before_action :enforce_oauth_scope!, only: [:index]

    def index
      # TODO Use routes to generate this (or swagger spec)
      render json: {
        name: 'Decisive Team API',
        version: '1.0.0', # TODO: Use config variable to track version
        auth: {
          type: 'OAuth2',
          scopes: [
            {
              name: 'read',
              description: 'Read-only access to your teams and decisions',
            },
            {
              name: 'write',
              description: 'Read and write access to your teams and decisions',
            },
          ],
        },
        routes: [
          {
            path: '/api/v1',
            methods: ['GET'],
          },
          {
            path: '/api/v1/me',
            methods: ['GET'],
          },
          {
            path: '/api/v1/teams',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/teams/:team_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/options',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/options/:option_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/options/:option_id/approvals',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/options/:option_id/approvals/:approval_id',
            methods: ['GET', 'PUT', 'DELETE'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/results',
            methods: ['GET'],
          },
          {
            path: '/api/v1/teams/:team_id/webhooks',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/teams/:team_id/webhooks/:webhook_id',
            methods: ['GET', 'DELETE'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/webhooks',
            methods: ['GET', 'POST'],
          },
          {
            path: '/api/v1/teams/:team_id/decisions/:decision_id/webhooks/:webhook_id',
            methods: ['GET', 'DELETE'],
          },
        ]
      }
    end

    private

    def current_user
      nil
    end

    def current_team
      nil
    end

    def current_resource_model
      nil
    end
  end
end