class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  VALID_PROVINCES = %w[AB BC MB NB NL NT NS NU ON PE QC SK YT].freeze

  validates :name, :email, :province, presence: true
  validates :province, inclusion: { in: VALID_PROVINCES }
end