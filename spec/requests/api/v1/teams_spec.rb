require 'spec_helper'
require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/teams', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let!(:team) { FactoryBot.create(:team) }
  let!(:team_member) { FactoryBot.create(:team_member, user: user, team: team) }
  let(:application) { Doorkeeper::Application.create!(
    name: "Test app",
    redirect_uri: "https://decisive.team",
    scopes: "read write"
  ) }
  let(:token) { Doorkeeper::AccessToken.create!(
    application_id: application.id,
    resource_owner_id: user.id,
    scopes: "read write"
  ) }

  let(:headers) do
    {
      "Authorization" => "Bearer #{token.token}",
      "Content-Type" => "application/json",
    }
  end
  

  path '/api/v1/teams' do

    get('List teams for current user') do
      tags 'Teams'
      description 'Fetches all teams for the authenticated user'
      operationId 'listTeams'
      security [{'OAuth2' => ['read']}]

      response(200, 'successful') do
        description 'List of teams'
        schema type: :array do
          items do
            key :'$ref', :Team
          end
        end

        before do
          get '/api/v1/teams', params: {}, headers: headers
        end
        it 'returns 200' do
          expect(response.code).to eq("200")
        end
      end
    end

    post('Create new team') do
      tags 'Teams'
      description 'Creates a new team for the authenticated user'
      operationId 'createTeam'
      security [{'OAuth2' => ['write']}]
      response(200, 'successful') do
        description 'Create a new team'
        let(:team_params) {
          {
            name: 'Test team',
            handle: 'testteam823738423948'
          }
        }
        before do
          post '/api/v1/teams', params: team_params.to_json, headers: headers
        end
        it 'returns 200' do
          expect(response.code).to eq("200")
        end
      end
    end

  end

  path '/api/v1/teams/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show team') do
      tags 'Teams'
      description 'Fetches team by ID for the authenticated user'
      operationId 'getTeam'
      security [{'OAuth2' => ['read']}]

      response(200, 'successful') do
        description 'List of teams'
        schema type: :array do
          items do
            key :'$ref', :Team
          end
        end

        before do
          get "/api/v1/teams/#{team.id}", params: {}, headers: headers
        end
        it 'returns 200 with the expected team' do
          expect(response.code).to eq("200")
          expect(response.body).to eq(team.to_json)
        end
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end
    end

    # put('update team') do
    #   response(200, 'successful') do
    #     let(:id) { '123' }

    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end

    # delete('delete team') do
    #   response(200, 'successful') do
    #     let(:id) { '123' }

    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end
  end
end
