class RepresentationSession < ApplicationRecord
  include Linkable
  include HasTruncatedId
  belongs_to :tenant
  belongs_to :studio
  belongs_to :representative_user, class_name: 'User'
  belongs_to :trustee_user, class_name: 'User'
  has_many :representation_session_associations, dependent: :destroy

  validates :began_at, presence: true
  validates :confirmed_understanding, inclusion: { in: [true] }

  def parse_and_create_link_records!
    # This method is overriding the method in the Linkable module
    # because the RepresentationSession model does not have a text field
    # but it can have backlinks from other models.
  end

  def api_json
    {
      id: id,
      confirmed_understanding: confirmed_understanding,
      began_at: began_at,
      ended_at: ended_at,
      elapsed_time: elapsed_time,
      activity_log: activity_log,
      studio_id: studio_id,
      representative_user_id: representative_user_id,
      trustee_user_id: trustee_user_id,
    }
  end

  def begin!
    # TODO - add a check for active representation session
    raise 'Must confirm understanding' unless confirmed_understanding
    # TODO - add more validations
    self.began_at = Time.current if began_at.nil?
    self.activity_log['activity'] ||= []
    save!
  end

  def active?
    ended_at.nil?
  end

  def elapsed_time
    return ended_at - began_at if ended_at
    return Time.current - began_at
  end

  def end!
    return if ended?
    self.activity_log['activity'] ||= []
    self.ended_at = Time.current
    save!
  end

  def ended?
    ended_at.present?
  end

  def expired?
    return ended? || Time.current > began_at + 24.hours
  end

  def validate_semantic_event!(semantic_event)
    # example = {
    #   "timestamp": "2021-09-01T12:34:56Z",
    #   "event_type": "create",
    #   "studio_id": "12345678",
    #   "main_resource": {
    #     "type": "Note",
    #     "id": "12345678",
    #     "truncated_id": "12345678",
    #   },
    #   "sub_resources": [
    #     {
    #       "type": "Option",
    #       "id": "87654321",
    #     },
    #   ],
    # }
    valid_keys = [:timestamp, :event_type, :studio_id, :main_resource, :sub_resources].sort
    raise "Invalid semantic event keys #{semantic_event.keys}" unless semantic_event.keys.sort == valid_keys
    valid_event_types = %w(create update confirm add_option vote commit pin unpin).sort
    raise "Invalid event type #{semantic_event[:event_type]}" unless valid_event_types.include?(semantic_event[:event_type])
    valid_main_resource_types = %w(Note Decision Commitment Sequence).sort
    raise "Invalid main resource type #{semantic_event[:main_resource][:type]}" unless valid_main_resource_types.include?(semantic_event[:main_resource][:type])
    valid_resource_keys = [:type, :id, :truncated_id].sort
    raise "Invalid main resource keys #{semantic_event[:main_resource].keys}" unless semantic_event[:main_resource].keys.sort == valid_resource_keys
    valid_sub_resource_types = %w(NoteHistoryEvent Option Approval CommitmentParticipant).sort
    valid_sub_resource_keys = [:type, :id].sort
    semantic_event[:sub_resources].each do |sub_resource|
      raise "Invalid sub resource type #{sub_resource[:type]}" unless valid_sub_resource_types.include?(sub_resource[:type])
      raise "Invalid sub resource keys #{sub_resource.keys}" unless sub_resource.keys.sort == valid_sub_resource_keys
    end
  end


  def record_activity!(request:, semantic_event:)
    raise 'Session has ended' if ended?
    raise 'Session has expired' if expired?
    validate_semantic_event!(semantic_event)
    ActiveRecord::Base.transaction do
      association = RepresentationSessionAssociation.unscoped.find_or_create_by!(
        representation_session: self,
        tenant_id: tenant_id,
        studio_id: studio_id,
        resource_type: semantic_event[:main_resource][:type],
        resource_id: semantic_event[:main_resource][:id],
        resource_studio_id: semantic_event[:studio_id],
      )
      semantic_event[:main_resource]['association_id'] = association.id
      semantic_event[:sub_resources].each do |sub_resource|
        RepresentationSessionAssociation.unscoped.find_or_create_by!(
          representation_session: self,
          tenant_id: tenant_id,
          studio_id: studio_id,
          resource_type: sub_resource[:type],
          resource_id: sub_resource[:id],
          resource_studio_id: semantic_event[:studio_id],
        )
        sub_resource[:association_id] = association.id
      end
      activity_log['activity'] ||= []
      activity_log['activity'] << {
        id: SecureRandom.uuid,
        happened_at: Time.current,
        semantic_event: semantic_event,
        request: {
          # Only include the basic information about the request
          # Do not include params or anything that could violate access permissions across studios.
          id: request.request_id,
          method: request.method,
          path: request.path,
        }
      }
      save!
    end
  end

  def title
    "Representation Session #{truncated_id}"
  end

  def path
    "/s/#{studio.handle}/r/#{truncated_id}"
  end

  def url
    "#{tenant.url}#{path}"
  end

  def human_readable_activity_log
    @human_readable_activity_log ||= [activity_log['activity'], nil].flatten.each_cons(2).map do |activity, next_activity|
      next if activity.nil? || activity['semantic_event'].nil?
      # for multiple sequetial vote events for the same decision within the same session, only show the last vote
      two_votes_on_same_decision = activity && next_activity &&
                                   activity['semantic_event']['event_type'] == 'vote' &&
                                   next_activity['semantic_event']['event_type'] == 'vote' &&
                                   activity['semantic_event']['main_resource']['id'] == next_activity['semantic_event']['main_resource']['id']
      next if two_votes_on_same_decision || activity.nil?
      happened_at = activity['happened_at']
      semantic_event = activity['semantic_event']
      verb_phrase = event_type_to_verb_phrase(semantic_event['event_type'])
      resource_model = semantic_event['main_resource']['type'].constantize
      main_resource = resource_model.unscoped.find(semantic_event['main_resource']['id'])
      studio = main_resource.studio
      {
        happened_at: happened_at,
        verb_phrase: verb_phrase,
        studio: studio,
        main_resource: main_resource,
      }
    end.compact
  end

  def event_type_to_verb_phrase(event_type)
    case event_type
    when 'create'
      'created'
    when 'update'
      'updated'
    when 'confirm'
      'confirmed reading'
    when 'add_option'
      'added an option to'
    when 'vote'
      'voted on'
    when 'commit'
      'joined'
    else
      raise "Unknown event type #{event_type}"
    end
  end

  def action_count
    human_readable_activity_log.count
  end

end