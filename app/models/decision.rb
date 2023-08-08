class Decision < ApplicationRecord
  include Tracked
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :team
  has_many :decision_participants, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :approvals # dependent: :destroy through options
  validates :question, presence: true
  validates :status, inclusion: { in: %w(ephemeral draft open closed) }, allow_nil: true

  after_save :schedule_destroy_ephemeral
  after_save :schedule_close_at_deadline

  def self.accessible_by(user)
    super.or(self.where(decision_participants: user.decision_participants))
  end    

  def self.grouped_by_urgency
    open_decisions = self.where(status: ['open', nil])
      .order(deadline: :asc)
      .group_by do |decision|
        if decision.deadline.nil?
          'no deadline'
        elsif decision.deadline < 1.day.from_now
          'closing soon'
        elsif decision.deadline < 1.week.from_now
          'closing this week'
        else
          'closing later'
        end
      end
    closed_decisions = self.where(status: 'closed')
      .order(deadline: :desc)
      .group_by do |decision|
        if decision.deadline.nil?
          'no deadline'
        elsif decision.deadline > Time.now
          'closed early'
        elsif (Time.now - decision.deadline) < 1.day
          'recently closed'
        else
          'closed'
        end
      end
    {
      'open' => open_decisions,
      'closed' => closed_decisions,
    }
  end

  def closed?
    status == 'closed'
  end

  def close!
    self.status = 'closed'
    save!
  end

  def close_if_deadline_passed!
    if deadline && deadline < Time.now
      close!
    end
  end

  def schedule_close_at_deadline
    if deadline && deadline > Time.now
      CloseDecisionJob.set(wait_until: deadline).perform_later(self.id)
    end
  end

  def destroy_ephemeral_at
    (deadline || created_at) + 1.hour
  end

  def schedule_destroy_ephemeral
    if status == 'ephemeral'
      # TODO - prevent duplicate jobs
      DestroyEphemeralJob.set(wait_until: destroy_ephemeral_at).perform_later(self.id)
    end
  end

  def destroy_ephemeral!
    if status == 'ephemeral'
      if destroy_ephemeral_at < Time.now
        destroy!
      else
        schedule_destroy_ephemeral
      end
    end
  end

  def participants
    decision_participants
  end

  def public?
    false # team_id == SystemResourceService.anonymous_team.id
  end

  def results
    return @results if @results
    @results = DecisionResult.where(decision_id: self.id)
  end

  def voter_count
    approvals.distinct.count(:decision_participant_id)
  end

  def path
    "/teams/#{self.team_id}/decisions/#{self.id}"
  end

  def shareable_link
    "https://#{ENV['HOSTNAME']}#{path}"
  end
end
