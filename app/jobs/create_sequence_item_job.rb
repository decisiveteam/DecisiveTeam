class CreateSequenceItemJob < ApplicationJob
  queue_as :sequences

  def perform(sequence)
    sequence.create_next_item_and_schedule!
  end
end
