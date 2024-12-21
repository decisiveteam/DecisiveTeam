# require 'chess'
class GamesController < ApplicationController

  def index
  end

  def create_chess_match
    ActiveRecord::Base.transaction do
      # a match is represented as a note
      @note = Note.create!(
        created_by: current_user,
        title: 'Chess Match',
        text: data_description({}),
        deadline: 1.day.from_now, # deadline doesn't matter
      )
      # participants are represented as note readers
      NoteHistoryEvent.create!(
        note: @note,
        user: current_user,
        event_type: 'read_confirmation',
        happened_at: Time.now,
      )
      # moves are represented as decisions
      @decision = Decision.create!(
        question: "Chess match #{@note.truncated_id}, move 1",
        description: data_description({
          match_id: @note.truncated_id,
          move_number: 1,
        }, links: [@note.shareable_link]),
        created_by: current_user,
        deadline: 1.day.from_now, # deadline doesn't matter
      )
      @commitment = Commitment.create!(
        title: "Chess match #{@note.truncated_id}, move 1",
        critical_mass: 1, # TODO - make this a param
        description: data_description({
          match_id: @note.truncated_id,
          decision_id: @decision.truncated_id,
          move_number: 1,
        }, links: [@decision.shareable_link]),
        created_by: current_user,
        deadline: 1.day.from_now, # deadline doesn't matter
      )
      @note.text = data_description({
        current_decision_id: @decision.truncated_id,
        current_commitment_id: @commitment.truncated_id,
        current_move_number: 1,
        moves: [],
      })
      @note.save!
    end
    redirect_to "/games/chess/#{@note.truncated_id}"
  end

  def show_chess_match
    @note = Note.find_by_truncated_id(params[:id])
    @move = current_move
    @game_state = game_state
    render layout: 'application', template: 'games/chess'
  end

  def join_chess_match
    @note = Note.find_by_truncated_id(params[:id])
    # participants are represented as note readers
    NoteHistoryEvent.find_or_create_by!(
      note: @note,
      user: current_user,
      event_type: 'read_confirmation'
    ) do |event|
      event.happened_at = Time.now
    end
    render json: game_state
  end

  def vote_on_chess_move
    @note = Note.find_by_truncated_id(params[:id])
    @move = current_move
    ActiveRecord::Base.transaction do
      participant = DecisionParticipantManager.new(
        decision: @decision,
        user: current_user
      ).find_or_create_participant
      @option = @decision.options.find_or_create_by!(title: params[:move]) do |option|
        option.decision_participant = participant
      end
      @approval = Approval.find_or_create_by!(
        decision: @decision,
        option: @option,
        decision_participant: participant
      ) do |approval|
        approval.value = 0
        approval.stars = 0
      end
      @approval.value = params[:accepted].to_s == 'true' ? 1 : 0
      @approval.stars = params[:preferred].to_s == 'true' ? 1 : 0
      @approval.save!
    end
    render json: {
      results: @decision.results
    }
  end

  def commit_to_chess_move
    @note = Note.find_by_truncated_id(params[:id])
    @move = current_move
    @commitment.join_commitment!(current_user)
    if @commitment.critical_mass_achieved?
      complete_move!
    end
    render json: game_state
  end

  def poll_chess_match
    @note = Note.find_by_truncated_id(params[:id])
    render json: game_state
  end

  private

  def current_studio
    # Special system studio for games
    return @current_studio if @current_studio
    @current_tenant = Tenant.scope_thread_to_tenant(subdomain: request.subdomain)
    # TODO - have this be created after tenant creation
    @current_studio = Studio.find_or_create_by(handle: 'games') do |studio|
      studio.name = 'Games'
      studio.created_by = @current_tenant.main_studio.created_by
      studio.settings = {
        system: true
      }
    end
    # Remove this
    @current_studio.add_user!(current_user) unless @current_studio.user_is_member?(current_user)
    @current_studio = Studio.scope_thread_to_studio(
      subdomain: request.subdomain,
      handle: @current_studio.handle
    )
    raise 'game studio must be system' unless @current_studio.settings['system'].to_s == 'true'
    @current_studio
  end

  def current_resource_model
    Studio
  end

  def complete_move!
    ActiveRecord::Base.transaction do
      decision_result = @decision.results[0].option_title
      @move ||= current_move
      @move['result'] = decision_result
      @decision.deadline = Time.now
      @decision.save!
      @game_state['moves'] << {
        'move_number' => @move['move_number'],
        'decision_id' => @move['decision'].truncated_id,
        'commitment_id' => @move['commitment'].truncated_id,
        'result' => decision_result,
        'finalized_at' => Time.now,
      }
      @game_state['current_move_number'] = @game_state['moves'].length + 1
      @decision = Decision.create!(
        question: "Chess match #{@note['truncated_id']}, move #{@game_state['current_move_number']}",
        description: data_description({
          match_id: @note.truncated_id,
          move_number: @game_state['current_move_number'],
        }, links: [@note.shareable_link]),
        created_by: current_user,
        deadline: 1.day.from_now, # deadline doesn't matter
      )
      @commitment = Commitment.create!(
        title: "Chess match #{@note.truncated_id}, move #{@game_state['current_move_number']}",
        critical_mass: 1, # TODO - make this a param
        description: data_description({
          match_id: @note.truncated_id,
          decision_id: @decision.truncated_id,
          move_number: @game_state['current_move_number'],
        }, links: [@decision.shareable_link]),
        created_by: current_user,
        deadline: 1.day.from_now, # deadline doesn't matter
      )
      @note.text = data_description({
        current_decision_id: @decision.truncated_id,
        current_commitment_id: @commitment.truncated_id,
        current_move_number: @game_state['current_move_number'],
        moves: @game_state['moves'],
      })
      @note.save!
    end
  end

  def data_description(data, links: nil)
    description = "\n" + DataMarkdownSerializer.serialize_for_embed_in_markdown(data: data, title: 'Game Data')
    if links
      # Links are separate from the data so that they generate navigable backlinks
      description += "\n\n## Links\n\n" + links.map { |link| "\n* #{link}" }.join("\n")
    end
    description
  end

  def game_state
    @game_state ||= DataMarkdownSerializer.extract_data_from_markdown(@note.text).first[:data].merge({
      'timestamp' => Time.now,
      'joined' => @note.user_has_read?(current_user),
    })
  end

  def current_move
    return @current_move if @current_move
    @decision = Decision.find_by_truncated_id(game_state['current_decision_id'])
    @commitment = Commitment.find_by_truncated_id(game_state['current_commitment_id'])
    @current_move = {
      'move_number' => game_state['current_move_number'],
      'decision' => @decision,
      'commitment' => @commitment,
    }
  end
end