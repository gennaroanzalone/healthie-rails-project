class Client < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :providers, through: :memberships
  has_many :journal_entries, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
