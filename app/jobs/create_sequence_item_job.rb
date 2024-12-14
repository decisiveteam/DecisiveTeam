class CreateSequenceItemJob < ApplicationJob
  queue_as :sequences

  def perform(sequence)
    begin
      sequence.create_next_item_and_schedule!
    rescue StandardError => e
      sequence.sequence_history_events.create!(
        user: sequence.studio.trustee_user,
        event_type: 'failed_item_create',
        happened_at: Time.current,
        data: {
          error: e.message,
        }
      )
      raise e
    end
  end
end
