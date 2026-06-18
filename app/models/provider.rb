class Provider < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :clients, through: :memberships

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # All journal entries across every client of this provider, oldest first.
  # Single query via a subquery on the join table — no N+1.
  def client_journal_entries
    JournalEntry
      .where(client_id: Membership.where(provider_id: id).select(:client_id))
      .oldest_first
  end
end
