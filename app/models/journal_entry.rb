class JournalEntry < ApplicationRecord
  belongs_to :client

  validates :body, presence: true

  # id is a deterministic tiebreaker for entries sharing a created_at.
  scope :oldest_first, -> { order(created_at: :asc, id: :asc) }
end
