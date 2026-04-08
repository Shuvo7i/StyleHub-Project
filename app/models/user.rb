class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  VALID_PROVINCES = %w[AB BC MB NB NL NT NS NU ON PE QC SK YT].freeze

  validates :province, inclusion: { in: VALID_PROVINCES }, allow_blank: true
end